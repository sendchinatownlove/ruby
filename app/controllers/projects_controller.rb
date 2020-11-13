# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show update]

  # GET /projects/:id
  def show
    json_response(project_json)
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def projects_json
    @projects.map { |c| project_json project: c }
  end

  def project_json(project: @project)
    ret = project.as_json
    ret['amount_raised'] = project.amount_raised
    ret
  end
end
