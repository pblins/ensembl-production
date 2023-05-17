=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
Copyright [2016-2023] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


=cut
use base ('Bio::EnsEMBL::Production::Pipeline::Common::Base');
package Bio::EnsEMBL::Production::Pipeline::Metadata::PayloadGenerator;

use warnings;
use strict;

sub run {
    my ($self) = @_;
    my $species = $self->param_required('species');
    my $core_adaptor = Bio::EnsEMBL::Registry->get_DBAdaptor($species, 'core');
    my $core_dbc = $core_adaptor->dbc;
    print $core_dbc->port;
    print $core_dbc->host;
    print $core_dbc->dbname;
}


1;