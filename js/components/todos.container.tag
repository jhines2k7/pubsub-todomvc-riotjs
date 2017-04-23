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
        import postal from 'postal/lib/postal.lodash'

        import { log } from "../../js/util";

        let eventStore = opts.event_store;

        this.todos = [];
        this.subscriptions = {};

        this.on('before-mount', function() {
            this.subscribe('sync', 'todo.add');
            this.subscribe('sync', 'todo.toggle');
            this.subscribe('sync', 'todo.toggle.all');
            this.subscribe('sync', 'todo.clear');
        });

        this.toggle_all = function() {
            let lastTodoEvent = eventStore.events.filter( (event) => {
                return event.topic === 'todo.add' || event.topic === 'todo.toggle'
                    || event.topic === 'todo.toggle.all' || event.topic === 'todo.clear';
            }).pop();

            let atLeastOneIncomplete = lastTodoEvent.data.todos.find( (todo) => {
                return todo.completed === false;
            });

            let markAllComplete = false;

            if(typeof atLeastOneIncomplete !== 'undefined') {
                markAllComplete = true;
            }

            let todos = lastTodoEvent.data.todos.map( (todo) => {
                return {
                    id: todo.id,
                    content: todo.content,
                    completed: markAllComplete
                };
            });

            let toggleAllEvent = {
                channel: "sync",
                topic: 'todo.toggle.all',
                eventType: 'click',
                data: {
                    todos: todos,
                    itemsLeft: markAllComplete === true ? 0 : todos.length,
                    completedItems: markAllComplete === true ? todos.length : 0,
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

            if(lastToggleEvent){
                todos = lastToggleEvent.data.todos.map( (todo) => {
                    if(todo.id === id) {
                        todo.completed = !completed;
                    }

                    return todo;
                });
            } else {
                let lastAddEvent = eventStore.events.filter( (event) => {
                    return event.topic === 'todo.add';
                }).pop();

                todos = lastAddEvent.data.todos.map( (todo) => {
                    if(todo.id === id) {
                        todo.completed = !completed;
                    }

                    return todo;
                });
            }

            let todoToggleEvent = {
                channel: "sync",
                topic: `todo.toggle`,
                eventType: 'click',
                data: {
                    todos: todos,
                    completedItems: !completed === true ? 1 : -1,
                    itemsLeft: !completed === true ? -1 : 1
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
                state.todos = event.data.todos;

                return state;
            }, {
                todos: []
            });
        }
    </script>
</todo-container>