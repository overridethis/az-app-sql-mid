import React, { Component } from 'react';

export class Home extends Component {
  static displayName = Home.name;

  constructor(props) {
    super(props);
    this.state = { people: [], loading: true };
  }

  componentDidMount() {
    this.populatePeopleData();
  }

  static renderPeopleTable(people) {
    return (
      <table className="table table-striped" aria-labelledby="tableLabel">
        <thead>
          <tr>
            <th>Firstname</th>
            <th>Lastname</th>
            <th>Phone</th>
            <th>Email</th>
            <th>Avatar</th>
          </tr>
        </thead>
        <tbody>
          {people.map(person =>
            <tr key={person.id}>
              <td>{person.lastName}</td>
              <td>{person.firstName}</td>
              <td>{person.phone}</td>
              <td>{person.email}</td>
              <td><img src={person.avatar} /></td>
            </tr>
          )}
        </tbody>
      </table>
    );
  }

  render() {
    let contents = this.state.loading
      ? <p><em>Loading...</em></p>
      : Home.renderPeopleTable(this.state.people);

    return (
      <div>
        <h1 id="tableLabel">Team Members</h1>
        <p>People associated with this group.</p>
        {contents}
      </div>
    );
  }

  async populatePeopleData() {
    const response = await fetch('people');
    const data = await response.json();
    this.setState({ people: data, loading: false });
  }
}
