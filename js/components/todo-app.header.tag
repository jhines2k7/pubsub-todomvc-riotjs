<todo-header>
    <header class="header">
        <h1>todos</h1>
        <input class="new-todo" onkeyup={ keyup } placeholder="What needs to be done?" autofocus>
    </header>

    <script>
        import postal from 'postal/lib/postal.lodash.min'

        import { log } from "../../js/util";

        let eventStore = opts.event_store;

        function guid() {
            return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
                s4() + '-' + s4() + s4() + s4();
        }

        function s4() {
            return Math.floor((1 + Math.random()) * 0x10000)
                .toString(16)
                .substring(1);
        }

        this.keyup = function(ev) {
            if(ev.keyCode === 13 && ev.currentTarget.value !== '') {
                let todoContent = event.currentTarget.value;
                event.currentTarget.value = '';

                let todos = [];

                let lastAddEvent = eventStore.events.filter( (event) => {
                    return event.topic === 'todo.add' || event.topic === 'todo.clear' || event.topic === 'todo.clear';
                }).pop();

                let lastRoutingEvent = eventStore.events.filter( (event) => {
                    return event.channel === 'routing';
                }).pop();

                let completedTodos = 0;

                if(lastAddEvent) {
                    todos = lastAddEvent.data.todos.map( (todo) => {
                        if(todo.completed === true) {
                            completedTodos++;
                        }

                        return {
                            id: todo.id,
                            content: todo.content,
                            completed: todo.completed
                        };
                    });
                }

                // add current item
                todos.push({
                    id: guid(),
                    content: todoContent,
                    completed: false
                });

                let addTodoEvent = {
                    channel: "sync",
                    topic: "todo.add",
                    eventType: 'keyup',
                    state: {
                        todos: todos,
                        filter: lastRoutingEvent.state.filter,
                        completedTodos: completedTodos,
                        markAllComplete: lastRoutingEvent.state.markAllComplete
                    }
                };

                eventStore.add(addTodoEvent);

                log('INFO', eventStore.events);
            }
        }.bind(this);
    </script>
</todo-header>