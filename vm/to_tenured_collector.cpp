#include "master.hpp"

namespace factor
{

to_tenured_collector::to_tenured_collector(factor_vm *myvm_) :
	copying_collector<tenured_space,to_tenured_policy>
	(myvm_,myvm_->data->tenured,to_tenured_policy(myvm_)) {}

void factor_vm::collect_to_tenured()
{
	to_tenured_collector collector(this);

	collector.trace_roots();
	collector.trace_contexts();
	collector.trace_cards(data->tenured);
	collector.trace_code_heap_roots();
	collector.cheneys_algorithm();
	update_dirty_code_blocks();

	reset_generation(data->aging);
	nursery.here = nursery.start;
}

}