
using System.Data.Common;
using System.Runtime.InteropServices;
using Azure.Storage;
using Azure.Storage.Queues;

namespace Test;
class Program
{
    const string queueName = "myqueue";

    const string url = $"https://192.168.1.115:10001/devstoreaccount1/{queueName}";

    const string account = "devstoreaccount1";
    const string key = "Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==";

    static async Task Main(string[] args)
    {
        var client = new QueueClient(
            new Uri(url),
            new StorageSharedKeyCredential(account, key)
        );

        var messageToSend = "Hello, Azure Queue Storage!";
        var response =await QueueManager.EnqueueAsync(client, messageToSend);

        Console.WriteLine($"Message sent with ID: {response.Value.MessageId}");

        var receivedMessage = await QueueManager.RetrieveNextMessageAsync(client);
        Console.WriteLine($"Received message: {receivedMessage}");
    }
}
