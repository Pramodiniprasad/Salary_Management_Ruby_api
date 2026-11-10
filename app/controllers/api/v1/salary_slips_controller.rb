module Api
  module V1
    class SalarySlipsController < BaseController
      def index
        authorize SalarySlip, :index?
        page, per_page = pagination_parameters
        return if performed?

        salary_slips = policy_scope(SalarySlip).includes(:organization)
        salary_slips = salary_slips.where(month: params[:month]) if params[:month].present?
        salary_slips = salary_slips.where(year: params[:year]) if params[:year].present?
        salary_slips = salary_slips.order(year: :desc, month: :desc, id: :desc)
        paginated_response(salary_slips, page: page, per_page: per_page, serializer: SalarySlipSerializer)
      end

      def show
        @salary_slip = policy_scope(SalarySlip).includes(:organization).find(params[:id])
        authorize @salary_slip, :show?
        render json: { data: SalarySlipSerializer.new(@salary_slip).as_json }
      end

      def create
        authorize SalarySlip.new(organization: current_user.organization), :create?

        salary = current_user.organization.salaries.find(salary_slip_params[:salary_id])
        @salary_slip = salary.organization.salary_slips.new(
          employee: salary.employee,
          salary: salary,
          month: salary_slip_params[:month],
          year: salary_slip_params[:year],
          basic_salary: salary.basic_salary,
          total_earnings: salary.gross_salary,
          total_deductions: salary.deductions,
          net_salary: salary.net_salary
        )
        if @salary_slip.save
          render json: { data: SalarySlipSerializer.new(@salary_slip).as_json }, status: :created
        else
          render_validation_errors(@salary_slip)
        end
      end

      def update
        @salary_slip = policy_scope(SalarySlip).find(params[:id])
        authorize @salary_slip, :update?

        if @salary_slip.update(salary_slip_update_params)
          render json: { data: SalarySlipSerializer.new(@salary_slip).as_json }
        else
          render_validation_errors(@salary_slip)
        end
      end

      private

      def salary_slip_params
        params.require(:salary_slip).permit(:salary_id, :month, :year)
      end

      def salary_slip_update_params
        params.require(:salary_slip).permit(:payment_status, :payment_date)
      end
    end
  end
end
