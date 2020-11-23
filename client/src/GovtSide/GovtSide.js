import React from 'react';
import './GovtSide.css'
import MintForm from './MintForm';
import { Container } from '@material-ui/core';
import AllotForm from './AllotForm';
import Button from '@material-ui/core/Button';
import TextField from '@material-ui/core/TextField';

class GovtSide extends React.Component {
    state = {
      dataKey: null,
      setGovtAddres: false,
    };

    setGovernmentAddress = async () => {
      if (this.state.setGovtAddres === true) {
        alert("Government Address already set");
      }
      else {
        const contract = this.props.drizzle.contracts.AddressTracker;
        let accounts = this.props.drizzleState.accounts;
        let result = contract.methods.setGovtAddress(accounts[0]).send({
          from: accounts[0],
          gas: 300000,
        });
        result.then((value) => {
          alert("Account Successfully Set");
          this.setState({
            setGovtAddres: true,
          });
          window.localStorage.setItem("setGovtAddress", JSON.stringify({
            setGovtAddres: true
          }));
        }).catch((err) => {
          alert(err);
        });
      }
      
    }
    setIssuingAuthority = async () => {
      if (this.state.setGovtAddres === false) {
        alert("Government address not set");
      }
      else{
        const contract = this.props.drizzle.contracts.AddressTracker;
        let accounts = this.props.drizzleState.accounts;
        var userId = parseInt(document.getElementById("UserId").value);
        if (isNaN(userId)) {
          alert("Please Enter User ID");
        }
        else{
          let result = contract.methods.issueAuthorisation(accounts[userId]).send({
            from: accounts[0],
            gas: 300000,
          });
          result.then((value) => {
            alert("Issuing Authority: " + userId + " Successfully Set");
          }).catch((err) => {
            alert(err);
          });

        }
      }
    }
    handleUserIdUpdate = (e) => {
      this.setState({
        userid: e.target.value,
      });
    }

    componentDidMount() {
        // const { drizzle } = this.props;
        // const contract = drizzle.contracts.MyStringStore;
    
        // let drizzle know we want to watch the `myString` method
        // const dataKey = contract.methods["myString"].cacheCall();
        // save the `dataKey` to local component state for later reference
        // this.setState({ dataKey });
      }

      render() {
        // get the contract state from drizzleState
        // const { MyStringStore } = this.props.drizzleState.contracts;
        // console.log(MyStringStore)
        // using the saved `dataKey`, get the variable we're interested in
        // const myString = MyStringStore.myString[this.state.dataKey];
        var button = <Button color="primary" onClick={this.setGovernmentAddress}>Set Government Address</Button>
        // if it exists, then we display its value
        return (
          <div>
            <TextField
              required
              id="UserId"
              name="UserId"
              label="User ID"
              fullWidth
              autoComplete="given-name"
              onKeyUp={this.handleUserIdUpdate}
            />
          <div className="flex-container container">
            <div className="flex-child mint">
              <Container>
                <MintForm drizzle={this.props.drizzle} drizzleState={this.props.drizzleState} />
              </Container>
            </div>
            <div className="flex-child allot">
              <Container>
                <AllotForm drizzle={this.props.drizzle} drizzleState={this.props.drizzleState} />
              </Container>
            </div>
          </div>
          <div>
            {[0].map(i => {
              console.log(window.localStorage);
              var val = JSON.parse(window.localStorage.getItem('setGovtAddress'));
              console.log(val);
              if (this.state.setGovtAddres === true || val.setGovtAddres === true) {
                return "";
              }
              else {
                return button;
              }
            })}
            <Button variant="contained" color='primary' onClick={this.setIssuingAuthority}>Set Issuing authority</Button>
          </div>
          </div>
        )
        // return <p>My stored string: {myString && myString.value}</p>;
      }
}

export default GovtSide;