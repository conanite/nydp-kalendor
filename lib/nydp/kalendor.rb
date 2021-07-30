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
      include Nydp::PluginHelper

      def name ; "Nydp/Kalendor plugin" ; end

      def base_path ; relative_path "../lisp/" ; end

      def load_rake_tasks ; end

      def loadfiles
        file_readers Dir.glob(relative_path '../lisp/kalendor-*.nydp').sort
      end

      def testfiles
        file_readers Dir.glob(relative_path '../lisp/tests/**/*.nydp')
      end

      def setup ns
        ::Kalendor::Instance::Base.send :include, ::Nydp::Kalendor::KalendorInstance
        store = ns.kalendor_store = ::Kalendor::Instance::Store.new
        factory = ::Kalendor::Factory.new
        ns.assign("kalendor/add"            , Nydp::Kalendor::Builtin::Store::Add        .new(store, factory))
        ns.assign("kalendor/find"           , Nydp::Kalendor::Builtin::Store::Find       .new(store, factory))
        ns.assign("kalendor/delete"         , Nydp::Kalendor::Builtin::Store::Delete     .new(store, factory))
        ns.assign("kalendor/names"          , Nydp::Kalendor::Builtin::Store::Names      .new(store, factory))
        ns.assign("kalendor/list"           , Nydp::Kalendor::Builtin::Store::List       .new(store, factory))
        ns.assign("kalendor/dates"          , Nydp::Kalendor::Builtin::Dates             .new(store, factory))
        ns.assign("kalendor-build/named"    , Nydp::Kalendor::Builtin::Builder::Named    .new(store, factory))
        ns.assign("kalendor-build/annual"   , Nydp::Kalendor::Builtin::Builder::Annual   .new(store, factory))
        ns.assign("kalendor-build/union"    , Nydp::Kalendor::Builtin::Builder::Union    .new(store, factory))
        ns.assign("kalendor-build/intersect", Nydp::Kalendor::Builtin::Builder::Intersect.new(store, factory))
        ns.assign("kalendor-build/subtract" , Nydp::Kalendor::Builtin::Builder::Subtract .new(store, factory))
        ns.assign("kalendor-build/list"     , Nydp::Kalendor::Builtin::Builder::DateList .new(store, factory))
        ns.assign("kalendor-build/interval" , Nydp::Kalendor::Builtin::Builder::Interval .new(store, factory))
        ns.assign("kalendor-build/weekday"  , Nydp::Kalendor::Builtin::Builder::Weekday  .new(store, factory))
        ns.assign("kalendor-build/month"    , Nydp::Kalendor::Builtin::Builder::Month    .new(store, factory))
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
        def call kal, from, upto
          lookup(kal).get_dates(to_date(from), to_date(upto)).to_a._nydp_wrapper
        end
      end

      module Store
        class Add    < Base ; def call  kal ; r2n @store.add n2r kal     ; end ; end
        class Find   < Base ; def call name ; r2n @store.find n2r name   ; end ; end
        class Delete < Base ; def call name ; r2n @store.delete n2r name ; end ; end
        class Names  < Base ; def call      ; r2n @store.names           ; end ; end
        class List   < Base ; def call      ; r2n @store.list            ; end ; end
      end

      module Builder
        class Weekday   < Base
          def call day, nth=:unset
            if nth == :unset
              @factory.weekday day
            else
              @factory.weekday day, nth
            end
          end
        end


        class Annual    < Base ; def call date, month ; @factory.annual date, month            ; end ; end
        class Union     < Base ; def call       *args ; @factory.union *args                   ; end ; end
        class Intersect < Base ; def call       *args ; @factory.intersect *args               ; end ; end
        class Subtract  < Base ; def call  keep, toss ; @factory.subtract keep, toss           ; end ; end
        class DateList  < Base ; def call       *args ; @factory.list *args                    ; end ; end
        class Interval  < Base ; def call  from, upto ; @factory.interval from, upto           ; end ; end
        class Month     < Base ; def call           m ; @factory.month m                       ; end ; end
        class Named     < Base ; def call   n, lbl, k ; k.name, k.label = n2r(n), n2r(lbl) ; k ; end ; end
      end
    end
  end
end

Nydp.plug_in Nydp::Kalendor::Plugin.new
