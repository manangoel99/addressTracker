// import ReadString from "./ReadString";
// import SetString from "./SetString";
import UserSide from "./UserSide/UserSide";
import GovtSide from "./GovtSide/GovtSide";
import AddressForm from "./Form";
import React from "react";
import { BrowserRouter as Router, Route, Link, Switch } from 'react-router-dom'; 
import { Navbar, Nav, Form, FormControl, Button, NavItem } from 'react-bootstrap';
import { Container } from "@material-ui/core";
// import Nav from 'react-bootstrap/Nav'

class App extends React.Component {
  state = { 
    loading: true, 
    drizzleState: null,
    setGovtAddress: false,
  };

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
          <Container>
          <Navbar bg="primary" expand="lg" variant="dark">
				    <Navbar.Brand as={Link} to="/">AddressTracker</Navbar.Brand>
				    <Navbar.Toggle aria-controls="basic-navbar-nav" />
				    <Navbar.Collapse id="basic-navbar-nav">
				    	<Nav className="mr-auto">
				    		<Nav.Link as={Link} to="/govt">Government Side</Nav.Link>
				    		<Nav.Link as={Link} to="/user">User Side</Nav.Link>
				    	</Nav>
				    </Navbar.Collapse>
			    </Navbar>
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
        </Container>

        </div>
      </Router>
    );
  }
}

export default App;