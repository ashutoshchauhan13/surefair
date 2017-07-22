import React, { Component } from 'react';
import { Link, Switch, Route, Redirect } from 'react-router-dom'
import Header from '../../Components/Header/';
import Sidebar from '../../Components/Sidebar/';
import Breadcrumb from '../../Components/Breadcrumb/';
import Aside from '../../Components/Aside/';
import Footer from '../../Components/Footer/';

import Dashboard from '../../views/Dashboard/'

class Full extends Component {
  render() {
    return (
      <div className="app">
        <Header />
        <div className="app-body">
          <Sidebar {...this.props}/>
          <main className="main">
            <Breadcrumb />
            <div className="container-fluid">
              <Switch>
                <Route path="/Investor" name="Investor" component={Dashboard}/>
                <Route path="/Client" name="Client" component={Dashboard}/>
                <Redirect from="/" to="/Investor"/>
              </Switch>
            </div>
          </main>
          <Aside />
        </div>
        <Footer />
      </div>
    );
  }
}

export default Full;