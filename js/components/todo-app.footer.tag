<todo-footer>
    <footer class="footer">
        <span class="todo-count"><strong>{ left_todo }</strong> { left_todo === 1 ? "todo left" : "todos left" }</span>

        <ul class="filters">
            <li>
                <a class={ selected: filter == 'all' } href="#/">All</a>
            </li>
            <li>
                <a class={ selected: filter == 'active' } href="#/active">Active</a>
            </li>
            <li>
                <a class={ selected: filter == 'completed' } href="#/completed">Completed</a>
            </li>
        </ul>
        <!-- Hidden if no completed todos are left ↓ -->
        <button if={ completed_todos > 0 } onclick={ clear } class="clear-completed">Clear completed</button>
    </footer>

    <script>
        import postal from 'postal/lib/postal.lodash.min'

        import { log } from "../../js/util";

        let eventStore = opts.event_store;

        this.left_todo = 0;
        this.subscriptions = {};
        this.completed_todos = 0;
        this.filter = 'all';
        this.markAllComplete;

        this.on('before-mount', function() {
            this.subscribe('sync', 'todo.add');
            this.subscribe('sync', 'todo.toggle');
            this.subscribe('sync', 'todo.toggle.all');
            this.subscribe('sync', 'todo.clear');
            this.subscribe('routing', 'todo.filter.all');
            this.subscribe('routing', 'todo.filter.active');
            this.subscribe('routing', 'todo.filter.completed');
        });

        this.clear = function() {
            let lastToggleEvent = eventStore.events.filter( (event) => {
                return event.topic === 'todo.toggle' || event.topic === 'todo.toggle.all';
            }).pop();

            let todos = lastToggleEvent.state.todos.filter( (todo) => {
                return todo.completed === false;
            });

            let clearCompletedEvent = {
                channel: 'sync',
                topic: 'todo.clear',
                eventType: 'click',
                state: {
                    todos: todos,
                    filter: this.filter,
                    completedTodos: 0,
                    markAllComplete: this.markAllComplete
                }
            };

            eventStore.add(clearCompletedEvent);
        }.bind(this);

        this.subscribe = function(channel, topic) {
            let subscription = postal.subscribe({
                channel: channel,
                topic: topic,
                callback: function(data, envelope) {
                    let events = eventStore.filter(this.subscriptions);

                    let state = this.reduce(events);

                    this.completed_todos = state.completedTodos;
                    this.filter = state.filter;
                    this.left_todo = state.leftTodo;
                    this.markAllComplete = state.markAllComplete;

                    this.update();

                }.bind(this)
            });

            this.subscriptions[topic] = subscription;

            return subscription;
        };

        this.reduce = function(events) {
            return events.reduce(function(state, event){
                if(event.topic === 'todo.toggle.all') {
                    if(event.state.markAllComplete === true) {
                        state.leftTodo = 0;
                        state.completedTodos = event.state.todos.length;
                    } else {
                        state.leftTodo = event.state.todos.length;
                        state.completedTodos = 0;
                    }
                } else if(event.topic === 'todo.clear'){
                    state.leftTodo = event.state.todos.length;
                    state.completedTodos = 0;
                } else if(event.channel !== 'routing') {
                    state.leftTodo += (event.state.todos - event.state.completedTodos);
                    state.completedTodos += event.state.completedTodos;
                }

                state.filter = event.state.filter;

                return state;
            }, {
                leftTodo: 0,
                completedTodos: 0,
                filter: 'all'
            });
        }
    </script>
</todo-footer>