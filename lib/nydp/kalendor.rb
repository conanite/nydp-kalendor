require "kalendor"
require "kalendor/instance"
require "kalendor/instance/store"
require "nydp"
require "nydp/kalendor/version"

module Nydp
  class Namespace
    attr_accessor :kalendor_store
  end

  module Kalendor
    module KalendorInstance
      include Nydp::AutoWrap
      def _nydp_whitelist
        @_nwl ||= Set.new([:name, :label])
      end
      def _nydp_procs ; [] ; end
    end

    class Plugin
      def name ; "Nydp/Kalendor plugin" ; end

      def relative_path name
        File.expand_path(File.join File.dirname(__FILE__), name)
      end

      def base_path ; relative_path "../lisp/" ; end

      def load_rake_tasks ; end

      def loadfiles
        Dir.glob(relative_path '../lisp/kalendor-*.nydp').sort
      end

      def testfiles
        Dir.glob(relative_path '../lisp/tests/**/*.nydp')
      end

      def setup ns
        ::Kalendor::Instance::Base.send :include, ::Nydp::Kalendor::KalendorInstance
        store = ns.kalendor_store = ::Kalendor::Instance::Store.new
        factory = ::Kalendor::Factory.new
        Symbol.mk("kalendor/add"            ,  ns).assign(Nydp::Kalendor::Builtin::Store::Add        .new store, factory)
        Symbol.mk("kalendor/find"           ,  ns).assign(Nydp::Kalendor::Builtin::Store::Find       .new store, factory)
        Symbol.mk("kalendor/delete"         ,  ns).assign(Nydp::Kalendor::Builtin::Store::Delete     .new store, factory)
        Symbol.mk("kalendor/names"          ,  ns).assign(Nydp::Kalendor::Builtin::Store::Names      .new store, factory)
        Symbol.mk("kalendor/list"           ,  ns).assign(Nydp::Kalendor::Builtin::Store::List       .new store, factory)
        Symbol.mk("kalendor/dates"          ,  ns).assign(Nydp::Kalendor::Builtin::Dates             .new store, factory)
        Symbol.mk("kalendor-build/named"    ,  ns).assign(Nydp::Kalendor::Builtin::Builder::Named    .new store, factory)
        Symbol.mk("kalendor-build/annual"   ,  ns).assign(Nydp::Kalendor::Builtin::Builder::Annual   .new store, factory)
        Symbol.mk("kalendor-build/union"    ,  ns).assign(Nydp::Kalendor::Builtin::Builder::Union    .new store, factory)
        Symbol.mk("kalendor-build/intersect",  ns).assign(Nydp::Kalendor::Builtin::Builder::Intersect.new store, factory)
        Symbol.mk("kalendor-build/subtract" ,  ns).assign(Nydp::Kalendor::Builtin::Builder::Subtract .new store, factory)
        Symbol.mk("kalendor-build/list"     ,  ns).assign(Nydp::Kalendor::Builtin::Builder::DateList .new store, factory)
        Symbol.mk("kalendor-build/interval" ,  ns).assign(Nydp::Kalendor::Builtin::Builder::Interval .new store, factory)
        Symbol.mk("kalendor-build/weekday"  ,  ns).assign(Nydp::Kalendor::Builtin::Builder::Weekday  .new store, factory)
        Symbol.mk("kalendor-build/month"    ,  ns).assign(Nydp::Kalendor::Builtin::Builder::Month    .new store, factory)
      end
    end

    module Builtin
      class Base
        include Nydp::Builtin::Base

        def initialize store, factory
          @store = store
          @factory = factory
        end

        def lookup       kal
          kal = n2r kal
          kal.respond_to?(:get_dates) ? kal : @store.find(kal)
        end

        def name         ; "kalendor/#{super}"     ; end
      end

      class Dates < Base
        include ::Kalendor::DateHelper
        def invoke_4 vm, kal, from, upto
          vm.r2n lookup(kal).get_dates(to_date(from), to_date(upto)).to_a
        end
      end

      module Store
        class Add    < Base ; def builtin_invoke_2  vm, kal ; vm.r2n @store.add n2r kal     ; end ; end
        class Find   < Base ; def builtin_invoke_2 vm, name ; vm.r2n @store.find n2r name   ; end ; end
        class Delete < Base ; def builtin_invoke_2 vm, name ; vm.r2n @store.delete n2r name ; end ; end
        class Names  < Base ; def builtin_invoke_1       vm ; vm.r2n @store.names           ; end ; end
        class List   < Base ; def builtin_invoke_1       vm ; vm.r2n @store.list            ; end ; end
      end

      module Builder
        class Weekday   < Base ; def builtin_invoke_3    vm, day, nth ; @factory.weekday day, nth              ; end
                                 def builtin_invoke_2         vm, day ; @factory.weekday day                   ; end ; end
        class Annual    < Base ; def builtin_invoke_3 vm, date, month ; @factory.annual date, month            ; end ; end
        class Union     < Base ; def builtin_invoke          vm, args ; @factory.union *(n2r args)             ; end ; end
        class Intersect < Base ; def builtin_invoke          vm, args ; @factory.intersect *(n2r args)         ; end ; end
        class Subtract  < Base ; def builtin_invoke_3  vm, keep, toss ; @factory.subtract keep, toss           ; end ; end
        class DateList  < Base ; def builtin_invoke          vm, args ; @factory.list *(n2r args)              ; end ; end
        class Interval  < Base ; def builtin_invoke_3  vm, from, upto ; @factory.interval from, upto           ; end ; end
        class Month     < Base ; def builtin_invoke_2           vm, m ; @factory.month m                       ; end ; end
        class Named     < Base ; def builtin_invoke_4   vm, n, lbl, k ; k.name, k.label = n2r(n), n2r(lbl) ; k ; end ; end
      end
    end
  end
end

Nydp.plug_in Nydp::Kalendor::Plugin.new
