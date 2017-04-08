#ifndef SHAKA_EVAL_PROC_CALL_H
#define SHAKA_EVAL_PROC_CALL_H

#include "IEvaluatorStrategy.h"
#include "IDataNode.h"
#include "IEnvironment.h"
#include "IProcedure.h"
#include "Procedure.h"
#include <vector>
#include <memory>
#include <type_traits>

// attempts to get the procedure bound in the current environment
// and call it on the arguments condained as the child nodes of the
// list node that the procedure is called on
// returns a pointer to the list node with its child node(s)
// updated to be the result(s) of the procedure call

namespace shaka {
namespace eval {

template <typename T, typename Key, typename Value>
class Proc_Call : public shaka::IEvaluatorStrategy<T, Key, Value> {

	std::shared_ptr<shaka::IDataNode<T>> evaluate(std::shared_ptr<shaka::IDataNode<T>> node,
			std::shared_ptr<shaka::IEnvironment<Key, Value>> env) {
		if (*node->get_child(0)->get_data().type() == typeid(shaka::Symbol)) {	
		// get the procedure associated with the symbol in the first child
		// of the PROC_CALL node in the environment
			std::shared_ptr<shaka::IProcedure<T>> proc = env->get_value(
					shaka::get<Key>(*node->get_child(0)->get_data()));
		}
		// did we successfully get a defined procedure?
		if (proc) {
			
			std::vector<T> args;
			std::shared_ptr<shaka::IDataNode<T>> list_node = node->get_child(1);
			std::shared_ptr<shaka::IDataNode<T>> next_argument;
			
			// if so, get all of the data out of the child nodes of the
			// LIST node and place them in an argument vector to pass to proc
			for (int i = 0; i < list_node->get_num_children(); i++) {
				next_argument = list_node->get_child(i);
				args.push_back(*next_argument->get_data());
			}
			
			// call the proc on the args vector and save the result in a
			// new vector of results
			std::vector<T> result = proc->call(args);

			// loop through the number of children in the LIST node and
			// remove the old children (the arguments to the proc call)
			for (int i = 0; i < list_node->get_num_children(); i++) {
				list_node->remove_child(i);
		
			}
			// add new children to the LIST node, which are the results
			// of our procedure call
			for (int i = 0; i < result.size(); i++) {
				list_node->insert_child(i, std::make_shared<Value>(result[i]));
			}
			
			return list_node;
		}
	
		// if we didn't manage to get a defined procedure out of the environment
		else {
			return node;
		}
	}

};
} // namespace eval
} // namespace shaka
#endif // SHAKA_EVAL_PROC_CALL_H