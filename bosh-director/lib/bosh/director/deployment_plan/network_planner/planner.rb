module Bosh::Director::DeploymentPlan
  module NetworkPlanner
    class Planner
      def initialize(static_ip_repo, logger)
        @static_ip_repo = static_ip_repo
        @logger = logger
      end

      def network_plan_with_dynamic_reservation(instance_plan, job_network)
        reservation = Bosh::Director::DesiredNetworkReservation.new_dynamic(instance_plan.instance, job_network.deployment_network)
        @logger.debug("Creating new dynamic reservation #{reservation} for instance '#{instance_plan.instance}'")
        Plan.new(reservation: reservation)
      end

      def network_plan_with_static_reservation(instance_plan, job_network)
        static_ip = @static_ip_repo.claim_static_ip_for_az_and_network(instance_plan.desired_az_name, job_network)

        reservation = Bosh::Director::DesiredNetworkReservation.new_static(instance_plan.instance, job_network.deployment_network, static_ip)
        @logger.debug("Creating new static reservation #{reservation} for instance '#{instance_plan.instance}'")
        Plan.new(reservation: reservation)
      end
    end
  end
end
