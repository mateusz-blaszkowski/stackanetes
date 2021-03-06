#!/usr/bin/python

# Copyright 2016 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import subprocess
import sys

SERVICE_PATH = "/usr/local/share/stackanetes/stackanetes-services"


def main():
    if len(sys.argv) != 2:
        exit("Please provide a 'run' or 'kill' as a script parameter")
    if sys.argv[1] not in ['run', 'kill']:
        exit("Invalid argument, please provide 'run' or 'kill'")

    services = load_all_services()
    manage_services(services, sys.argv[1])


def load_all_services():
    services = []
    for _, _, files_names in os.walk(SERVICE_PATH):
        services.extend(files_names)

    services = [file_name[:-4] for file_name in services]

    return services


def manage_services(services, manage_type):
    for service_name in services:
        cmd = ['stackanetes', '--config-dir',
               '/etc/stackanetes', '--debug', manage_type]
        cmd.append(service_name)
        print cmd
        subprocess.call(cmd)

if __name__ == "__main__":
    main()
