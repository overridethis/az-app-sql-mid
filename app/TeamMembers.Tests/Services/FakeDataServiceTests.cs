using FluentAssertions;
using Flurl.Http;
using Microsoft.Extensions.Options;
using TeamMembers.Services;

namespace TeamMembers.Tests;

public class FakeDataServiceTests
{
    [Fact(Skip="This test requires a Mockaroo API key.")]
    public async Task GetPeopleAsync_is_not_empty()
    {
        // Arrange
        var options = new OptionsWrapper<MockarooOptions>(new MockarooOptions("{{KEY_GOES_HERE}}"));
        var service = new FakeDataService(options);

        // Act
        var people = await service.GetPeopleAsync();

        // Assert
        people.Should().NotBeEmpty();
    }
}