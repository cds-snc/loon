# ![loon_small2](https://user-images.githubusercontent.com/5498428/54842801-473ee900-4ca9-11e9-9cb4-2bbfe8ba2b31.png) dashboard-backend

[![Phase](https://img.shields.io/badge/Phase-Discovery-b7028e.svg)](https://digital.canada.ca/products/)

### Purpose

The purpose of this application is to provide a high-performance and scalable scheduled job runner that emits JSON data using web socket connections. It allows for Second granularity of job execution in multiple concurrent processes.

Additionally data is only emitted if a client is connected. If no clients are connected, no jobs are executed.

The applications leverages the [Phoenix](https://phoenixframework.org/) application framework to ensure performance and reliability. Further it uses [Quantum](https://github.com/quantum-elixir/quantum-core) to supervise jobs with the ability to spread them across multiple nodes.

### Accessing the data

The data service is running at: `wss://loon-server.herokuapp.com/socket`

Get a list of all available data sources here: `https://loon-server.herokuapp.com`

Data is shared through web socket connections. Each client creates one socket connection and can the connect to multiple channels prefixed with `data_source:`. For example, to get a listing of memory usage on the server, you would connect to the `data_source:server_memory` channel. Each channel is just a multiplexed connection over the initial socket.

The data sent through the web socket is an object with a `data` and a `timestamp` key and looks something like this:

```JSON
{
   "data": <<THE EMITED DATA>>,
   "timestamp":"2019-03-17T18:36:32.977228Z"
}
```

To connect to the web socket you can use the client [listed here](https://hexdocs.pm/phoenix/channels.html#client-libraries).

Sample implementation for a React application:

`App.js` - please note that you only ever need one `socket` connection.

```JavaScript
import React, { Component } from "react";
import { Socket } from "phoenix";
import ServerMemory from "./widgets/server_memory";

const DATA_URL = "wss://loon-server.herokuapp.com/socket";

class App extends Component {
  constructor(props) {
    super(props);
    this.socket = new Socket(DATA_URL);
    this.socket.connect();
  }

  render() {
    return (
      <div className="App">
        <ServerMemory socket={this.socket} />
      </div>
    );
  }
}

export default App;
```

`widgets/server_memory`

```JavaScript
import React, { Component } from "react";

class Ping extends Component {
  constructor(props) {
    super(props);
    this.state = { data: {} };
    let channel = props.socket.channel("data_source:server_memory", {});
    channel.join().receive("error", resp => {
      console.log("Unable to join: ", resp);
    });
    channel.on("data", payload => {
      this.setState({ data: payload.data });
    });
  }

  listItems = () => {
    const data = this.state.data;
    return Object.keys(data).map(key => {
      return (
        <li key={key}>
          {key}: {data[key]}
        </li>
      );
    });
  };

  render() {
    return (
      <div className="memory-widget">
        <ul>{this.listItems()}</ul>
      </div>
    );
  }
}
```

### Writing your own Jobs

You can easily add new jobs to the server by placing them in the `lib/loon/jobs` directory. Job have a `using` macro that defines a set of
utility functions that enable to Job to be processes by the system. All you need to do is define the `job/0` function that can return a **JSON convertible object**.

A simple implementation that send a "pong" message might look something like this.

```Elixir
defmodule Loon.Jobs.Pong do
  @moduledoc false

  use Loon.Jobs,
    description: "Returns the string pong at minute intervals",
    schedule: "@minutely"

  @doc """
  Returns the string `pong`
  """
  def job do
    "pong"
  end
end
```

The sent data would look like this:

```JSON
{
   "data":"pong",
   "timestamp":"2019-03-17T18:36:32.977228Z"
}
```

Each job requires a `description` and a `schedule`. The format of `schedule` is defined [here](https://hexdocs.pm/quantum/crontab-format.html#basics).

The name of the data source is inferred through the name of the module. In this case the module name is `Pong` so the data service name is `pong`. By convention the `CamelCase` name of a Module gets changed in to `under_score` case. This ensures that jobs do not have namespace collisions.

### Local Development

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Questions?

Please contact us through any of the multiple ways listed on our [website](https://digital.canada.ca/).
