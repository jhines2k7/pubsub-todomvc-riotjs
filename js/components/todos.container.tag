<todo-container>
    <section class="main">
        <input class="toggle-all" type="checkbox">
        <label for="toggle-all">Mark all as complete</label>
        <ul class="todo-list">
            <!-- These are here just to show the structure of the list items -->
            <!-- List items should get the class `editing` when editing and `completed` when marked as completed -->
            <li each={ todos } id={ id } class="completed">
                <div class="view">
                    <input class="toggle" type="checkbox" checked>
                    <label>{content}</label>
                    <button class="destroy"></button>
                </div>
                <input class="edit" value="Create a TodoMVC template">
            </li>
        </ul>
    </section>

    <script>
        import postal from 'postal/lib/postal.lodash'

        import { log } from "../../js/util";

        let eventStore = opts.event_store;

        this.todos = [];
        this.subscriptions = {};
        this.markAsComplete = false;

        this.on('mount', function() {
            this.subscribe('sync', 'todo.add');
        });

        this.subscribe = function(channel, topic) {
            let subscription = postal.subscribe({
                channel: channel,
                topic: topic,
                callback: function(data, envelope) {
                    let events = eventStore.filter(this.subscriptions);

                    let state = this.reduce(events);

                    this.todos = state.todos;
                    this.markAsComplete = state.markAsComplete;

                    this.update();

                }.bind(this)
            });

            this.subscriptions[topic] = subscription;

            return subscription;
        }

        this.reduce = function(events) {
            return events.reduce(function(state, event){
                state.todos = event.data.todos;

                if(event.topic === 'todo.add' || event.topic === 'todo.toggle') {
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