import React from 'react';
import Grid from '@material-ui/core/Grid';
import Typography from '@material-ui/core/Typography';
import TextField from '@material-ui/core/TextField';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Checkbox from '@material-ui/core/Checkbox';
import Button from '@material-ui/core/Button';

class AllotForm extends React.Component {

  allotToken = async () => {
    var lat = document.getElementById("AllotLatitude").value;
    var long = document.getElementById("AllotLongitude").value;
    var address_line_1 = document.getElementById("AllotAddress1").value;
    var address_line_2 = document.getElementById("AllotAddress2").value;
    var residents = document.getElementById("residents").value.trim();
    residents = residents.split(",");
    if (residents.length == 0) {
      alert("There must be at least one resident");
    }
    else {
      for (var i = 0; i < residents.length; i++) {
        residents[i] = parseInt(residents[i]);
      }
      var latitude = parseFloat(lat.trim()) * 10**8;
      var longitude = parseFloat(long.trim()) * 10**8;
      if (isNaN(longitude) || isNaN(latitude)) {
        console.log("YO")
        alert("Longitude and Latitude must be numbers")
      }
      else {
        const web3 = this.props.drizzle.web3;
        var nonce = Math.floor(Math.random() * 10**8);
        var obj = web3.eth.abi.encodeParameters(
          ['uint', 'uint', 'string', 'string', 'uint[]', 'uint'],
          [latitude, longitude, address_line_1, address_line_2, residents, nonce]
        );
        var hash = web3.utils.sha3(obj, {encoding: "hex"});
        console.log(hash);
        alert("Your Nonce is " + nonce + " Please do not forget")
        // let a = await web3.eth.getAccounts();
        // const { drizzle, drizzleState } = this.props;
        // const contract = drizzle.contracts.MyStringStore;
        // let result = contract.methods.set("HAHA").send({
        //   from: drizzleState.accounts[0],
        // });
        // result.then((val) => {
        //   console.log(val);
        // }).catch((err) => {
        //   console.log(err);
        // });
      }
    }
  }

  render() {
    return (
      <React.Fragment>
        <Typography variant="h6" gutterBottom>
          Allot Token
        </Typography>
        <Grid container spacing={3}>
          <Grid item xs={12} sm={6}>
            <TextField
              required
              id="AllotLatitude"
              name="Latitude"
              label="Latitude"
              fullWidth
              autoComplete="given-name"
            />
          </Grid>
          <Grid item xs={12} sm={6}>
            <TextField
              required
              id="AllotLongitude"
              name="Longitude"
              label="Longitude"
              fullWidth
              autoComplete="family-name"
            />
          </Grid>
          <Grid item xs={12}>
            <TextField
              required
              id="AllotAddress1"
              name="address1"
              label="Address line 1"
              fullWidth
              autoComplete="shipping address-line1"
            />
          </Grid>
          <Grid item xs={12}>
            <TextField
              id="AllotAddress2"
              name="address2"
              label="Address line 2"
              fullWidth
              autoComplete="shipping address-line2"
            />
          </Grid>
          <Grid item xs={12} sm={12}>
            <TextField
              required
              id="residents"
              name="Residents"
              label="Comma seperated addresses of residents"
              fullWidth
              autoComplete="shipping address-level2"
            />
          </Grid>
          <Button variant="contained" color='primary' onClick={this.allotToken}>Allot Token</Button>
        </Grid>
      </React.Fragment>
    );
  }
  
}

export default AllotForm;