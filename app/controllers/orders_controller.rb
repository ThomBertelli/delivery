class OrdersController<ApplicationController
  skip_forgery_protection
  before_action :set_order, only: [:update_state, :show]
  before_action :authenticate!,:only_buyers!
  include ActionController::Live

  def index
    @orders = Order.where(buyer: current_user)
  end

  def create
    @order = Order.new(order_params) { |o| o.buyer = current_user }

    if @order.save
      render :create, status: :created
    else
      render json: {errors: @order.errors, status: :unprocessable_entity}
    end
  end

  def pay
    order = Order.find(params[:id])
    value = params[:value]
    number = params[:number]
    valid = params[:valid]
    cvv = params[:cvv]

    # Enfileira o job para ser executado posteriormente
    PaymentJob.perform_later(order: order, value:value, number: number, valid:valid, cvv: cvv)
    # Renderiza uma resposta ou redireciona conforme necessário
    render json: { status: 'Pagamento enfileirado com sucesso' }, status: :ok
  end

  def order_watch
      response.headers["Content-Type"] = "text/event-stream"
      sse = SSE.new(response.stream, retry: 300, event: "watching-orders")
      sse.write({hello: "world!"}, event: "watching-order")

      EventMachine.run do
        EventMachine::PeriodicTimer.new(15) do

          order = Order.where(id: params[:order_id]).last
          puts "################"
          puts order.state
          case order.state

          when "created"
            message = { time: Time.now, order: order }
            sse.write(message, event: "order-created")
          when "accepted"
            message = { time: Time.now, order: order }
            sse.write(message, event: "order-accepted")
          when "rejected"
            message = { time: Time.now, order: order }
            sse.write(message, event: "order-rejected")
          when "paid"
            message = { time: Time.now, order: order }
            sse.write(message, event: "order-paid")
          when "notPaid"
            message = { time: Time.now, order: order }
            sse.write(message, event: "order-not-paid")
          when "sended"
            message = { time: Time.now, order: order }
            sse.write(message, event: "order-sended")
          else
            sse.write(message, event: "no")
          end
        end
      end
    rescue IOError, ActionController::Live::ClientDisconnected
      sse.close if sse
    ensure
      sse.close if sse
  end

  # PATCH /orders/:id/update_status
  def update_state
    if @order.update(order_state_params)
      render json: { success: true,  }
    else
      render json: { success: false, errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render :show, status: :ok, location: @order }
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit([:store_id])
  end


  def order_state_params
    params.require(:order).permit(:state)
  end

  def valid_state_transition?(state)
    @order.state_paths.any? { |path| path.events.map(&:name).include?(state.to_sym) }
  end

end
