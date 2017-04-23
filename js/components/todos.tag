<todo-app>
    <section class="todoapp">
        <todo-header event_store={ opts }></todo-header>
        <!-- This section should be hidden by default and shown when there are todos -->
        <todo-container if={ num_todos > 0 } event_store={ opts }></todo-container>
        <!-- This footer should hidden by default and shown when there are todos -->
        <todo-footer if={ num_todos > 0 } event_store={ opts }></todo-footer>
    </section>

    <script>
        import postal from 'postal/lib/postal.lodash'

        import { log } from "../../js/util";

        let eventStore = opts;

        this.subscriptions = {};
        this.num_todos = 0;

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

                    this.num_todos = state.num_todos;

                    this.update();

                }.bind(this)
            });

            this.subscriptions[topic] = subscription;

            return subscription;
        };

        this.reduce = function(events) {
            return events.reduce(function(state, event){
                state.num_todos = event.data.todos.length;

                return state;
            }, {
                num_todos: 0
            });
        }
    </script>
</todo-app>