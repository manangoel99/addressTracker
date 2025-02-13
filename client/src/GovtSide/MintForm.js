import React from 'react';
import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';

class MintForm extends React.Component {

  mintCoin = async () => {
    var lat = document.getElementById("NewTokenLatitude").value;
    var long = document.getElementById("NewTokenLongitude").value;
    var address_line_1 = document.getElementById("NewTokenAddress1").value;
    var address_line_2 = document.getElementById("NewTokenAddress2").value;
    var latitude = parseFloat(lat.trim()) * 10**8;
    var longitude = parseFloat(long.trim()) * 10**8;
    if (isNaN(longitude) || isNaN(latitude)) {
      console.log("YO")
      alert("Longitude and Latitude must be numbers")
    }
    else {
      const web3 = this.props.drizzle.web3;
      var obj = web3.eth.abi.encodeParameters(
        ['uint', 'uint', 'string', 'string'],
        [latitude, longitude, address_line_1, address_line_2]
      );
      var hash = web3.utils.sha3(obj, {encoding: "hex"});
      var userId = parseInt(document.getElementById("UserId").value);
      if (isNaN(userId)) {
        alert("Please Enter User ID");
      }
      else {
        const { drizzle, drizzleState } = this.props;
        const contract = drizzle.contracts.AddressTracker;
        console.log(hash, drizzleState.accounts[userId]);
        let result = contract.methods.mintToken(hash).send({
          from: drizzleState.accounts[userId],
          gas: 3000000,
        });
        result.then((val) => {
          alert("Token Minted Successfully");
          console.log(val);
        }).catch((err) => {
          alert(err);
        });
      }
    }
  }
  render() {
    return (
      <div>
      <React.Fragment>
        <Typography variant="h6" gutterBottom>
          Create New Token
        </Typography>
        <Grid container spacing={3}>
          <Grid item xs={12} sm={6}>
            <TextField
              required
              id="NewTokenLatitude"
              name="NewTokenLatitude"
              label="Latitude"
              fullWidth
              autoComplete="given-name"
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              required
              id="NewTokenLongitude"
              name="NewTokenLongitude"
              label="Longitude"
              fullWidth
              autoComplete="family-name"
            />
          </Grid>
          <Grid item xs={12}>
            <TextField
              required
              id="NewTokenAddress1"
              name="NewTokenAddress1"
              label="Address line 1"
              fullWidth
              autoComplete="shipping address-line1"
            />
          </Grid>
          <Grid item xs={12}>
            <TextField
              id="NewTokenAddress2"
              name="NewTokenAddress2"
              label="Address line 2"
              fullWidth
              autoComplete="shipping address-line2"
            />
          </Grid>
          <Button variant="contained" color='primary' onClick={this.mintCoin}>Mint Token</Button>
        </Grid>
      </React.Fragment>
      </div>
    );
  }
  
}

export default MintForm;