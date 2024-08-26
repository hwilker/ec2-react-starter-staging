import React, {Component} from 'react';

async function fetchRoute(url) {
  let response = await fetch(url);
  if (response.ok) {
    return await response.json();
  }
}
/*
async function fetchRoute(url) {
  try {
    // let result = await axios.get(`http://localhost:5100${url}`)
    let result = await axios.get(url);
    return result.data;
  }
  catch(err) {
    console.log(`Error fetching ${url}:`, err)
  }
}
 */

class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      hello: '',
      goodbye: ''
    }
  }

  componentDidMount() {
    /*
    This construction is how you would execute a route upon loading a module, ie for
     data needed for setup
     */
    fetchRoute('/api/hello')
      .then((result)=>{
        this.setState({hello: result.msg})
      })
  }

  doClick = async (url) => {
    /*
    this construction is how you would execute a route based upon an event such as a
     button click. Instead of using async/await you could also use the .then
      construction that is used in componentDidMount.
     */
    let result = await fetchRoute('/api/goodbye')
    this.setState({goodbye: result.msg})
  }

  render() {
    return (
      <div className="App">
        <p>React/Node Starter</p>
        <p>{this.state.hello}</p>
        <button onClick={this.doClick}>Click me!</button>
        <p>{this.state.goodbye}</p>
      </div>);
  }

}

export default App;
