require 'spec_helper'

module Bosh::Director
  module DeploymentPlan::Stages
    describe CleanupStemcellReferencesStage do
      subject { CleanupStemcellReferencesStage.new(deployment_planner) }

      let!(:stemcell_model) { Bosh::Director::Models::Stemcell.create(name: 'stemcell', version: '2', cid: 'abc') }
      let(:unused_stemcell) { Bosh::Director::Models::Stemcell.create(name: 'stemcell', version: '1', cid: 'def') }
      let(:unused_stemcell_custom_cpi) do
        Bosh::Director::Models::Stemcell.create(name: 'stemcell', version: '1', cid: 'def', cpi: 'custom')
      end
      let(:unused_stemcell_custom_cpi2) do
        Bosh::Director::Models::Stemcell.create(name: 'stemcell', version: '1', cid: 'def', cpi: 'custom2')
      end

      let(:deployment_model) { Models::Deployment.make }
      let(:deployment_planner) { instance_double(DeploymentPlan::Planner) }
      let(:planner_stemcell) do
        DeploymentPlan::Stemcell.parse(
          'alias' => 'default',
          'name' => 'stemcell',
          'version' => '2',
        )
      end

      before do
        Bosh::Director::App.new(Bosh::Director::Config.load_hash(SpecHelper.spec_get_director_config))
        allow(deployment_planner).to receive(:model).and_return(deployment_model)

        planner_stemcell.bind_model(deployment_model)
        unused_stemcell.add_deployment(deployment_model)
        unused_stemcell_custom_cpi.add_deployment(deployment_model)
        unused_stemcell_custom_cpi2.add_deployment(deployment_model)
      end

      describe '#perform' do
        context 'when using vm types and stemcells' do
          before do
            allow(deployment_planner).to receive(:stemcells).and_return(
              'default' => planner_stemcell,
            )
          end

          context 'when the stemcells associated with the deployment have diverged from those associated with the planner' do
            it 'it removes the given deployment from any stemcell it should not be associated with' do
              expect(stemcell_model.deployments).to include(deployment_model)
              expect(unused_stemcell.deployments).to include(deployment_model)
              expect(unused_stemcell_custom_cpi.deployments).to include(deployment_model)
              expect(unused_stemcell_custom_cpi2.deployments).to include(deployment_model)

              subject.perform

              expect(stemcell_model.reload.deployments).to include(deployment_model)
              expect(unused_stemcell.reload.deployments).to_not include(deployment_model)
              expect(unused_stemcell_custom_cpi.reload.deployments).to_not include(deployment_model)
              expect(unused_stemcell_custom_cpi2.reload.deployments).to_not include(deployment_model)
            end
          end
        end
      end
    end
  end
end
