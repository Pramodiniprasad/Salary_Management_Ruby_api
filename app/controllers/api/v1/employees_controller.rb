module Api
  module V1
    class EmployeesController < BaseController
      def index
        authorize Employee, :index?
        employees = policy_scope(Employee).order(:id)
        render json: { data: employees.map { |employee| EmployeeSerializer.new(employee).as_json } }
      end

      def show
        @employee = policy_scope(Employee).find(params[:id])
        authorize @employee, :show?
        render json: { data: EmployeeSerializer.new(@employee).as_json }
      end

      def create
        @employee = Employee.new(organization: current_user.organization)
        authorize @employee, :create?

        attributes = employee_params
        employee_user = current_user.organization.users.employee.find(attributes.delete(:user_id))
        @employee = current_user.organization.employees.new(attributes)
        @employee.user = employee_user

        if @employee.save
          render json: { data: EmployeeSerializer.new(@employee).as_json }, status: :created
        else
          render_validation_errors(@employee)
        end
      end

      def update
        @employee = policy_scope(Employee).find(params[:id])
        authorize @employee, :update?

        if @employee.update(employee_update_params)
          render json: { data: EmployeeSerializer.new(@employee).as_json }
        else
          render_validation_errors(@employee)
        end
      end

      def destroy
        @employee = policy_scope(Employee).find(params[:id])
        authorize @employee, :destroy?

        if @employee.destroy
          head :no_content
        else
          render_validation_errors(@employee)
        end
      end

      private

      def employee_params
        params.require(:employee).permit(
          :user_id, :employee_code, :first_name, :last_name, :email, :phone,
          :designation, :department, :date_of_joining, :employment_status
        )
      end

      def employee_update_params
        employee_params.except(:user_id)
      end
    end
  end
end
