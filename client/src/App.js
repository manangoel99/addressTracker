// import ReadString from "./ReadString";
// import SetString from "./SetString";
import UserSide from "./UserSide/UserSide";
import GovtSide from "./GovtSide/GovtSide";
import AddressForm from "./Form";
import React from "react";
import { BrowserRouter as Router, Route, Link, Switch } from 'react-router-dom'; 
import { Navbar, Nav, Form, FormControl, Button, NavItem } from 'react-bootstrap';

class App extends React.Component {
  state = { loading: true, drizzleState: null };

  componentDidMount() {
    const { drizzle } = this.props;

    // subscribe to changes in the store
    this.unsubscribe = drizzle.store.subscribe(() => {

      // every time the store updates, grab the state from drizzle
      const drizzleState = drizzle.store.getState();

      // check to see if it's ready, if so, update local component state
      if (drizzleState.drizzleStatus.initialized) {
        this.setState({ loading: false, drizzleState });
      }
    });
  }

  componentWillUnmount() {
    this.unsubscribe();
  }

  render() {
    if (this.state.loading) return "Loading Drizzle...";
    return (
      <Router>
        <div className="App">
          <ul className="App-header">
            <li><Link to="/govt">Government Side</Link></li>
            <li><Link to="/user">User Side</Link></li>
          </ul>
          <Switch>
            <Route
             exact path='/' 
             render={
               () => <UserSide drizzle={this.props.drizzle} drizzleState={this.state.drizzleState} />
              } 
            />
            <Route
             exact path='/user' 
             render={
               () => <UserSide drizzle={this.props.drizzle} drizzleState={this.state.drizzleState} />
              } 
            />
            <Route
             exact path='/govt' 
             render={
               () => <GovtSide drizzle={this.props.drizzle} drizzleState={this.state.drizzleState} />
              } 
            />
          </Switch>
        </div>
      </Router>
    );
  }
}

export default App;