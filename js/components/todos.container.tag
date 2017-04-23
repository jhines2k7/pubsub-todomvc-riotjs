<todo-container>
    <section class="main">
        <input id="toggle-all" class="toggle-all" type="checkbox">
        <label onclick={ toggle_all.bind(null, markAllComplete) } for="toggle-all">Mark all as complete</label>
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
        this.markAllComplete = false;

        this.on('before-mount', function() {
            this.subscribe('sync', 'todo.add');
            this.subscribe('sync', 'todo.toggle.complete');
            this.subscribe('sync', 'todo.toggle.incomplete');
            this.subscribe('sync', 'todo.toggle.all.complete');
            this.subscribe('sync', 'todo.toggle.all.incomplete');
        });

        this.toggle_all = function(markAllComplete) {
            let lastAddEvent = eventStore.events.filter( (event) => {
                return event.topic === 'todo.add';
            }).pop();

            let todos = [];

            let toggleAllEvent;

            if(!markAllComplete === true) {
                todos = lastAddEvent.data.todos.map( (todo) => {
                    return {
                        id: todo.id,
                        content: todo.content,
                        completed: true
                    };
                });

                toggleAllEvent = {
                    channel: "sync",
                    topic: 'todo.toggle.all.complete',
                    eventType: 'click',
                    data: {
                        todos: todos,
                        markAllComplete: true,
                        itemsLeft: 0,
                        completedItems: todos.length
                    }
                }
            } else {
                todos = lastAddEvent.data.todos.map( (todo) => {
                    return {
                        id: todo.id,
                        content: todo.content,
                        completed: false
                    };
                });

                toggleAllEvent = {
                    channel: "sync",
                    topic: 'todo.toggle.all.incomplete',
                    eventType: 'click',
                    data: {
                        todos: todos,
                        markAllComplete: false,
                        itemsLeft: todos.length,
                        completedItems: 0
                    }
                }
            }

            eventStore.add(toggleAllEvent);
        };

        this.toggle = function(id, completed){
            let lastToggleEvent = eventStore.events.filter( (event) => {
                return event.topic === 'todo.toggle';
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

            let todoToggleEvent;

            if(!completed === true) {
                todoToggleEvent = {
                    channel: "sync",
                    topic: `todo.toggle.complete`,
                    eventType: 'click',
                    data: {
                        todos: todos,
                        completedItems: 1,
                        itemsLeft: -1
                    }
                };

                eventStore.add([todoToggleEvent]);
            } else {
                todoToggleEvent = {
                    channel: "sync",
                    topic: `todo.toggle.incomplete`,
                    eventType: 'click',
                    data: {
                        todos: todos,
                        completedItems: -1,
                        itemsLeft: 1
                    }
                };

                eventStore.add(todoToggleEvent);
            }
        };

        this.subscribe = function(channel, topic) {
            let subscription = postal.subscribe({
                channel: channel,
                topic: topic,
                callback: function(data, envelope) {
                    let events = eventStore.filter(this.subscriptions);

                    let state = this.reduce(events);

                    this.todos = state.todos;
                    this.markAllComplete = state.markAllComplete;

                    this.update();

                }.bind(this)
            });

            this.subscriptions[topic] = subscription;

            return subscription;
        }

        this.reduce = function(events) {
            return events.reduce(function(state, event){
                state.todos = event.data.todos;

                if(event.topic === 'todo.add') {
                    return state;
                } else if(event.topic === 'todo.toggle.all.complete' || event.topic === 'todo.toggle.all.incomplete') {
                    state.markAllComplete = event.data.markAllComplete;

                    return state;
                } else if(event.topic === 'todo.toggle.complete' || event.topic === 'todo.toggle.incomplete') {
                    return state;
                }
            }, {
                todos: [],
                markAllComplete: false
            });
        }
    </script>
</todo-container>