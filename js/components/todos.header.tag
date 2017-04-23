<todo-header>
    <header class="header">
        <h1>todos</h1>
        <input class="new-todo" onkeyup={ keyup } placeholder="What needs to be done?" autofocus>
    </header>

    <script>
        import postal from 'postal/lib/postal.lodash'

        import { log } from "../../js/util";

        let eventStore = opts;

        this.keyup = function(ev) {
            if(ev.keyCode === 13 && ev.currentTarget.value !== '') {
                let todoContent = event.currentTarget.value;
                event.currentTarget.value = '';

                log('INFO', todoContent);

                let todos = [];

                let addTodoEvent = {
                    channel: "sync",
                    topic: "todo.add",
                    eventType: 'keyup',
                    data: {
                        todos: todos,
                        itemsLeft: 1
                    }
                };

                eventStore.add(addTodoEvent);
            }
        }.bind(this);
    </script>
</todo-header>