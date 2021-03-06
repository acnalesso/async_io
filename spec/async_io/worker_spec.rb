require 'spec_helper'
require 'async_io/worker'

module AsyncIO
  Worker.class_eval do
    public(:fallback)
  end

  describe Worker do

    let(:payload) { ->(r) { r } }
    let(:task)    { -> { :am_a_dog } }
    let(:worker)  { Worker.new(payload, task) }

    it { worker.should respond_to :done }

    it "should not be done as task is not finished" do
      worker.done.should be_false
    end

    it "must call payload and pass task as its argument" do
      worker.call.should eq(:am_a_dog)
    end

    context "Getting a task done" do
      it "should set done to its last finished task" do
        worker.call
        worker.done.should eq(:am_a_dog)
      end
    end

    describe "#try" do
      it { worker.should respond_to :try }

      context "failed" do
        it "should call fallback" do
          worker.should_receive(:fallback)
          worker.try { raise "failed" }
        end
      end

      context "success" do
        it "should not call fallback" do
          worker.should_not_receive(:fallback)
          worker.try { :happy }
        end
      end

      context "#fallback" do
        let(:fallback) { worker.fallback("notice") }

        it "should have a notice" do
          fallback.notice.should eq("notice")
        end

        it "should have a worker" do
          fallback.worker.should eq worker
        end

        it "should return nil when method not found" do
          fallback.will_return_nil.should be_nil
        end
      end

    end

  end
end
