using Flurl;
using Flurl.Http;
using Flurl.Http.Configuration;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using TeamMembers.Data.Models;

namespace TeamMembers.Services;

public interface IFakeDataService
{
   Task<IEnumerable<Person>> GetPeopleAsync(int number = 50);
}

public class MockarooOptions
{
    public MockarooOptions() : this(string.Empty) { }
    public MockarooOptions(string apiKey)
    {
        this.ApiKey = apiKey;
    }

    public string ApiKey { get; set; } = string.Empty;
}

public class FakeDataService : IFakeDataService
{
    static FakeDataService() 
    {
        FlurlHttp.Configure(settings =>
        {
            var jsonSettings = new JsonSerializerSettings
            {
                NullValueHandling = Newtonsoft.Json.NullValueHandling.Ignore,
                ObjectCreationHandling = ObjectCreationHandling.Replace,
                ContractResolver = new CamelCasePropertyNamesContractResolver()
            };
            settings.JsonSerializer = new NewtonsoftJsonSerializer(jsonSettings);
        });
    }

    public record Schema(string Name, string Type, string? Formula = null, string? Format = null, int PercentBlank = 0);

    private readonly string _endpoint;
    private readonly List<Schema> _schema = new()
    {
        new Schema("lastName", "Last Name"),
        new Schema("firstName", "First Name"),
        new Schema("email", "Email Address"),
        new Schema("phone", "Phone", Format:"(###) ###-####"),
        new Schema("avatar", "Avatar")
    };

    public FakeDataService(IOptions<MockarooOptions> config)
    {
        var endpoint = "https://api.mockaroo.com/api/generate.json";
        this._endpoint = $"{endpoint}?key={config.Value.ApiKey}";
    }

    public async Task<IEnumerable<Person>> GetPeopleAsync(int number = 50)
    {
        var endpoint = $"{this._endpoint}&count={number}";
        var response = await endpoint.PostJsonAsync(this._schema);
        var people = await response.GetJsonAsync<List<Person>>();
        return people;
    }
}