module Api
  module V1
    class SalariesController < BaseController
      def index
        authorize Salary, :index?
        page, per_page = pagination_parameters
        return if performed?

        salaries = policy_scope(Salary).order(:id)
        paginated_response(salaries, page: page, per_page: per_page, serializer: SalarySerializer)
      end

      def show
        @salary = policy_scope(Salary).find(params[:id])
        authorize @salary, :show?
        render json: { data: SalarySerializer.new(@salary).as_json }
      end

      def create
        authorize Salary.new(organization: current_user.organization), :create?

        @salary = current_user.organization.salaries.new(salary_params.except(:employee_id))
        @salary.employee = current_user.organization.employees.find(salary_params[:employee_id])

        if @salary.save
          render json: { data: SalarySerializer.new(@salary).as_json }, status: :created
        else
          render_validation_errors(@salary)
        end
      end

      def update
        @salary = policy_scope(Salary).find(params[:id])
        authorize @salary, :update?

        if @salary.update(salary_update_params)
          render json: { data: SalarySerializer.new(@salary).as_json }
        else
          render_validation_errors(@salary)
        end
      end

      def destroy
        @salary = policy_scope(Salary).find(params[:id])
        authorize @salary, :destroy?

        if @salary.destroy
          head :no_content
        else
          render_validation_errors(@salary)
        end
      end

      private

      def salary_params
        params.require(:salary).permit(
          :employee_id, :basic_salary, :hra, :allowances, :deductions,
          :effective_from, :effective_to
        )
      end

      def salary_update_params
        salary_params.except(:employee_id)
      end
    end
  end
end
