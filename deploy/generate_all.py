#!/usr/bin/env python3
"""
Gera os .jar de configuracao OSB 12c para todos os projectos do repo.
"""
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(SCRIPT_DIR)
sys.path.insert(0, SCRIPT_DIR)

import generate_sbconfig

PROJECTS = [
    'RNU-ProcessarSituacaoUtilizador',
    'Rot-RNU-ProcessarSituacaoUtilizador',
]

if __name__ == '__main__':
    for project in PROJECTS:
        project_dir = os.path.join(REPO_ROOT, project)
        if not os.path.isdir(project_dir):
            print("SKIP: %s nao existe" % project_dir)
            continue
        out_jar = os.path.join(SCRIPT_DIR, "%s_sbconfig.jar" % project)
        generate_sbconfig.generate(project_dir, out_jar)
        print("")
