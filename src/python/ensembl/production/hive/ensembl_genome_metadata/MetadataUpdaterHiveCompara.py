
#  See the NOTICE file distributed with this work for additional information
#  regarding copyright ownership.
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#      http://www.apache.org/licenses/LICENSE-2.0
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.


from ensembl.production.hive.BaseProdRunnable import BaseProdRunnable
from ensembl.production.metadata.updater import CoreMetaUpdater

class MetadataUpdaterHiveCompara(BaseProdRunnable):
    def fetch_input(self):
        input_data = self.get_input_data()
        self.param("metadata_uri", input_data.get("metadata_uri"))
        self.param("database_uri", input_data.get("database_uri"))
        self.param("release", input_data.get("release"))

    def run(self):
        # CoreMetaUpdater(self.param("database_uri"),self.param("metadata_uri"),self.param("release"))
        raise Exception("compara not implemented yet")
