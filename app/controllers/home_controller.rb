class HomeController < ApplicationController
  # before_action :authenticate_v1_customer!
  # before_action :authenticate_v1_admin!

  def admin_search
    uid = params[:uid]
    @admin = Admin.find_by(uid: uid)
    @company = Company.find(@admin.company_id)

    render json: { 
      admin: @admin,
      comapny: @company
    }
  end

  def customer_search
    uid = params[:uid]
    @customer = Customer.find_by(uid: uid)
    render json: { 
      customer: @customer
    }
  end

  def trainer_search
    uid = params[:uid]
    @trainer = Trainer.find_by(uid: uid)
    render json: { 
      traine: @trainer
    }
  end

  def master_admin_search
    uid = params[:uid]
    @master_admin = MasterAdmin.find_by(uid: uid)
    render json: { 
      master_admin: @master_admin
    }
  end

  def index
    @all_company = Company.all
    render json: @all_company
  end

  def today
    # @black_schedules = BlackSchedule.where(company_id: params[:company_id])
    index_params
    @this_days_times = make_time_schedule_in_one_day(params[:year].to_i, params[:month].to_i, params[:day].to_i)
  
    @today_schedules = []
    @store_array = []
    Store.where(company_id: params[:company_id],deactivate: false).each do |s|
      @store_array << s
      schedules_array = []
      @this_days_times.each do |t|
        start = [t[0].hour.to_s, t[0].min.to_s]
        if start[1] == "0"
          start = [t[0].hour.to_s, "00"]
        end
        fin = [(t[1]-60*10).hour.to_s, (t[1]-60*10).min.to_s]
        if fin[1] == "0"
          fin = [fin[0], "00"]
        end
        time = [start, fin]
        datetime_start = t[0].to_datetime
        datetime_fin = t[1].to_datetime
        black_schedules = BlackSchedule.where(company_id: params[:company_id], store_id: s.id)
                          .where(not_free_time_start: datetime_start..datetime_fin)
                          .or(BlackSchedule.where(not_free_time_finish: datetime_start..datetime_fin))
                          .or(BlackSchedule.where('not_free_time_start <= ?', datetime_start).where('? <= not_free_time_finish', datetime_fin))
                          .eager_load(:trial_session).select("*").to_a
        
        customer_appointments = Customer.where(company_id: params[:company_id]).joins(:appointments).joins(:customer_info).select("customers.*, appointments.*, customer_infos.*").where(appointments: { appointment_time: t[0], store_id: s.id }).to_a
        schedule_infos = black_schedules.append(customer_appointments).flatten
        schedules_array << [time, schedule_infos]
      end

      @today_schedules << {  store_name: s.store_name,  
                            value: {
                              store_id: s.id,
                              store_rooms_num: s.number_of_rooms,
                              store_rooms_num_for_js: Array.new(s.number_of_rooms,s.store_name),
                              schedules: schedules_array
                            }
                          }
    end
    render json: {today_schedules: @today_schedules }
  end

  def oneday
    index_params
    year = params[:year].to_i
    month = params[:month].to_i
    day = params[:day].to_i
    @this_days_times = make_time_schedule_in_one_day(year, month, day)
    @this_day = Date.new(year, month, day)
    @pre_day = @this_day - 1.day
    @tomorrow = @this_day + 1.day
    render json: { this_day_times: @this_days_times, this_day: @this_day, pre_day: @pre_day, tomorrow: @tomorrow }
  end

  private

    def index_params
      @year = ((params[:year]).to_i)
      @month = ((params[:month]).to_i)
      @wday = Date.new((params[:year]).to_i,(params[:month]).to_i,1).wday
      @days_of_the_week = ["???","???","???","???","???","???","???"]
      @days_of_month = calendar_array((params[:year]).to_i%4)
      num = ((params[:month]).to_i) -1
      pre_num = num - 1
      if pre_num == -1
        pre_num = 11
      end
      @days = @days_of_month[num]
      @pre_days = @days_of_month[pre_num]
    end

    def calendar_array(ok)
      if ok == 0
        a =  [
          [1,31],[1,29],[1,31],
          [1,30],[1,31],[1,30],
          [1,31],[1,31],[1,30],
          [1,31],[1,30],[1,31]
        ]
      else
        a =  [
          [1,31],[1,28],[1,31],
          [1,30],[1,31],[1,30],
          [1,31],[1,31],[1,30],
          [1,31],[1,30],[1,31]
        ]
      end
      return a
    end
end
