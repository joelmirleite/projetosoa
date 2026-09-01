#!/usr/bin/env python3
"""
Gera um .jar de configuracao OSB 12c (formato "Import Resources") a partir de um
directorio de projecto OSB. Nao necessita de configjar, Maven nem JDeveloper.

O formato gerado e identico ao export nativo da consola OSB:
  - ExportInfo na raiz do jar (primeira entrada)
  - recursos com caminho relativo, separador '/'
  - SEM META-INF, SEM entradas de directorio

Uso:
    python3 deploy/generate_sbconfig.py <caminho_projecto> [ficheiro_saida.jar]
"""
import os
import re
import sys
import zipfile
from xml.etree import ElementTree as ET

DATACLASS = {
    "XMLSchema": "com.bea.wli.sb.resources.config.impl.SchemaEntryDocumentImpl",
    "Xquery": "com.bea.wli.sb.resources.config.impl.XqueryEntryDocumentImpl",
    "WSDL": "com.bea.wli.sb.resources.config.impl.WsdlEntryDocumentImpl",
    "JCA": "com.bea.wli.sb.resources.config.impl.JcaEntryDocumentImpl",
    "Pipeline": "com.bea.wli.sb.pipeline.config.impl.PipelineEntryDocumentImpl",
    "ProxyService": "com.bea.wli.sb.services.impl.ProxyServiceEntryDocumentImpl",
    "BusinessService": "com.oracle.xmlns.servicebus.business.config.impl.BusinessServiceEntryDocumentImpl",
    "AlertDestination": "com.bea.wli.monitoring.alert.impl.AlertDestinationImpl",
}

EXT_PRIORITY = {
    ".XMLSchema": 1,
    ".WSDL": 2,
    ".JCA": 3,
    ".Xquery": 4,
    ".BusinessService": 5,
    ".AlertDestination": 6,
    ".Pipeline": 7,
    ".ProxyService": 8,
}


def local_name(tag):
    if tag is None:
        return None
    return tag.split('}')[-1]


def discover_resources(project_dir):
    """Lista todos os recursos OSB no projecto."""
    resources = []
    for root, dirs, files in os.walk(project_dir):
        for fname in files:
            ext = os.path.splitext(fname)[1]
            if ext in EXT_PRIORITY:
                full = os.path.join(root, fname)
                rel = os.path.relpath(full, project_dir).replace(os.sep, '/')
                instance = rel[:-len(ext)]
                resources.append({
                    'full': full,
                    'relpath': rel,
                    'instance': instance,
                    'ext': ext,
                    'type': EXT_PRIORITY[ext],
                    'typeid': ext[1:],
                })
    return sorted(resources, key=lambda r: (r['type'], r['relpath']))


def build_instance_map(project_dir, project_name, resources):
    """Mapeia ref (projecto/caminho) -> (typeid, extref) para recursos conhecidos."""
    instance_map = {}
    for r in resources:
        instance_id = "%s/%s" % (project_name, r['instance'])
        extref = "%s$%s" % (r['typeid'], instance_id.replace('/', '$'))
        instance_id_no_ext = instance_id
        instance_map[instance_id_no_ext] = (r['typeid'], extref)
        # alguns ficheiros referenciam-se sem project name dentro do mesmo projecto
        instance_map[r['instance']] = (r['typeid'], extref)
    return instance_map


def _collect_refs(elem, parent_tag, refs):
    tag = local_name(elem.tag)
    if 'ref' in elem.attrib:
        ref = elem.attrib['ref']
        # ignorar refs que nao sao dependencias/runtime de recursos
        if tag == 'jca-file' and parent_tag == 'provider-specific':
            pass
        elif parent_tag == 'dependency':
            pass
        elif tag == 'resource' and parent_tag == 'dependency':
            pass
        else:
            refs.add(ref)
    for child in elem:
        _collect_refs(child, tag, refs)


def find_refs(full_path, instance_map):
    """Extrai refs relevantes de um ficheiro OSB."""
    refs = set()
    try:
        tree = ET.parse(full_path)
    except ET.ParseError:
        # fallback: regex simples
        with open(full_path, 'r', encoding='utf-8') as f:
            text = f.read()
        for m in re.finditer(r'ref="([^"]+)"', text):
            refs.add(m.group(1))
        return refs

    _collect_refs(tree.getroot(), None, refs)
    return refs


def extref_for_ref(ref, instance_map, project_name):
    """Converte um ref em string extref do ExportInfo."""
    # ref pode ja incluir o nome do projecto (ex: RNU-.../Resources/Schemas/X)
    if ref in instance_map:
        return instance_map[ref][1]
    # tentar adicionar nome do projecto
    prefixed = "%s/%s" % (project_name, ref)
    if prefixed in instance_map:
        return instance_map[prefixed][1]
    # referencias de sistema conhecidas
    if ref.startswith('System/SMTP Servers/'):
        server = ref.split('/')[-1]
        return "SMTPServer$System$SMTP Servers$%s" % server
    return None


def build_export_info(project_name, resources, instance_map):
    lines = []
    lines.append('<?xml version="1.0" encoding="UTF-8"?>')
    lines.append('<xml-fragment name="" version="v2" xmlns:imp="http://www.bea.com/wli/config/importexport">')
    lines.append('    <imp:properties>')
    lines.append('        <imp:property name="username" value="equipa.rnu"/>')
    lines.append('        <imp:property name="description" value=""/>')
    lines.append('        <imp:property name="exporttime" value="Mon Sep 01 09:00:00 WEST 2026"/>')
    lines.append('        <imp:property name="productname" value="Oracle Service Bus"/>')
    lines.append('        <imp:property name="productversion" value="12.2.1.3.0"/>')
    lines.append('        <imp:property name="projectLevelExport" value="false"/>')
    lines.append('    </imp:properties>')

    for r in resources:
        instance_id = "%s/%s" % (project_name, r['instance'])
        jarname = "%s/%s" % (project_name, r['relpath'])
        lines.append('    <imp:exportedItemInfo instanceId="%s" typeId="%s">' % (instance_id, r['typeid']))
        lines.append('        <imp:properties>')
        lines.append('            <imp:property name="representationversion" value="0"/>')
        lines.append('            <imp:property name="dataclass" value="%s"/>' % DATACLASS[r['typeid']])
        lines.append('            <imp:property name="isencrypted" value="false"/>')
        lines.append('            <imp:property name="jarentryname" value="%s"/>' % jarname)

        refs = find_refs(r['full'], instance_map)
        for ref in sorted(refs):
            ext = extref_for_ref(ref, instance_map, project_name)
            if ext:
                lines.append('            <imp:property name="extrefs" value="%s"/>' % ext)

        lines.append('        </imp:properties>')
        lines.append('    </imp:exportedItemInfo>')

    lines.append('</xml-fragment>')
    return "\n".join(lines) + "\n"


def generate(project_dir, out_jar=None):
    project_dir = os.path.abspath(project_dir)
    project_name = os.path.basename(project_dir)
    if out_jar is None:
        out_jar = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                               "%s_sbconfig.jar" % project_name)
    else:
        out_jar = os.path.abspath(out_jar)

    resources = discover_resources(project_dir)
    if not resources:
        raise SystemExit("Nenhum recurso OSB encontrado em: %s" % project_dir)

    instance_map = build_instance_map(project_dir, project_name, resources)
    export_info = build_export_info(project_name, resources, instance_map)

    if os.path.exists(out_jar):
        os.remove(out_jar)

    with zipfile.ZipFile(out_jar, 'w', zipfile.ZIP_DEFLATED) as z:
        z.writestr("ExportInfo", export_info)
        for r in resources:
            arcname = "%s/%s" % (project_name, r['relpath'])
            z.write(r['full'], arcname)

    print("OK: %s" % out_jar)
    print("Entradas: %d (ExportInfo + %d recursos)" % (len(resources) + 1, len(resources)))
    return out_jar


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Uso: %s <caminho_projecto> [ficheiro_saida.jar]" % sys.argv[0])
        sys.exit(1)
    project_dir = sys.argv[1]
    out_jar = sys.argv[2] if len(sys.argv) > 2 else None
    generate(project_dir, out_jar)
