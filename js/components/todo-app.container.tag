<todo-container>
    <section class="main">
        <input id="toggle-all" class="toggle-all" type="checkbox">
        <label onclick={ toggle_all } for="toggle-all">Mark all as complete</label>
        <ul class="todo-list">
            <!-- List items should get the class `editing` when editing and `completed` when marked as completed -->
            <li each={ todos } id={ id } class={ completed: completed }>
                <div class="view">
                    <input onclick={ toggle.bind(null, id, completed) } class="toggle" type="checkbox" checked={ completed }>
                    <label>{content}</label>
                    <button class="destroy"></button>
                </div>
                <input class="edit" value="Create a TodoMVC template">
            </li>
        </ul>
    </section>

    <style>
        #toggle-all::before {
            content: "❯";
            font-size: 22px;
            color: rgb(230, 230, 230);
            padding: 10px 27px;
        }
    </style>

    <script>
        import postal from 'postal/lib/postal.lodash.min'

        import { log } from "../../js/util";

        let eventStore = opts.event_store;

        this.todos = [];

        this.subscriptions = {};

        this.on('before-mount', function() {
            this.subscribe('sync', 'todo.add');
            this.subscribe('sync', 'todo.toggle');
            this.subscribe('sync', 'todo.toggle.all');
            this.subscribe('sync', 'todo.clear');
            this.subscribe('routing', 'todo.filter.all');
            this.subscribe('routing', 'todo.filter.active');
            this.subscribe('routing', 'todo.filter.completed');
        });

        this.toggle_all = function() {
            let lastTodoEvent = eventStore.events.filter( (event) => {
                return event.topic === 'todo.add' || event.topic === 'todo.toggle'
                    || event.topic === 'todo.toggle.all' || event.topic === 'todo.clear';
            }).pop();

            let atLeastOneIncomplete = lastTodoEvent.state.todos.find( (todo) => {
                return todo.completed === false;
            });

            let markAllComplete = false;

            if(typeof atLeastOneIncomplete !== 'undefined') {
                markAllComplete = true;
            }

            let todos = lastTodoEvent.state.todos.map( (todo) => {
                return {
                    id: todo.id,
                    content: todo.content,
                    completed: markAllComplete
                };
            });

            let toggleAllEvent = {
                channel: 'sync',
                topic: 'todo.toggle.all',
                eventType: 'click',
                data: {
                    todos: todos,
                    filter: this.filter,
                    completedTodos: markAllComplete === true ? todos.length : 0,
                    markAllComplete: markAllComplete
                }
            };

            eventStore.add(toggleAllEvent);
        };

        this.toggle = function(id, completed){
            let lastToggleEvent = eventStore.events.filter( (event) => {
                return event.topic === 'todo.toggle' || event.topic === 'todo.toggle.all'
                    || event.topic === 'todo.clear' || event.topic === 'todo.add';
            }).pop();

            let todos = [];
            let lastAddEvent = {};

            if(typeof lastToggleEvent !== 'undefined'){
                todos = lastToggleEvent.state.todos.map( (todo) => {
                    if(todo.id === id) {
                        todo.completed = !completed;
                    }

                    return todo;
                });
            } else {
                lastAddEvent = eventStore.events.filter( (event) => {
                    return event.topic === 'todo.add';
                }).pop();

                todos = lastAddEvent.state.todos.map( (todo) => {
                    if(todo.id === id) {
                        todo.completed = !completed;
                    }

                    return todo;
                });
            }

            let todoToggleEvent = {
                channel: 'sync',
                topic: 'todo.toggle',
                eventType: 'click',
                state: {
                    todos: todos,
                    filter: this.filter,
                    completedTodos: !completed === true ? todos.length + 1 : todos.length - 1,
                    markAllComplete: typeof lastToggleEvent !== 'undefined' ? lastToggleEvent.state.markAllComplete : lastAddEvent.state.markAllComplete
                }
            };

            eventStore.add(todoToggleEvent);
        };

        this.subscribe = function(channel, topic) {
            let subscription = postal.subscribe({
                channel: channel,
                topic: topic,
                callback: function(data, envelope) {
                    let events = eventStore.filter(this.subscriptions);

                    let state = this.reduce(events);

                    this.todos = state.todos;

                    this.update();

                }.bind(this)
            });

            this.subscriptions[topic] = subscription;

            return subscription;
        };

        this.reduce = function(events) {
            return events.reduce(function(state, event){
                state.todos = event.state.todos;

                return state;
            }, {
                todos: []
            });
        }
    </script>
</todo-container>