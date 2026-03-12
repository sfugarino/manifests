using Azure;
using Azure.Storage.Queues;
using Azure.Storage.Queues.Models;

namespace Test;
public static class QueueManager
{
    public static async Task<Response<SendReceipt>> EnqueueAsync(QueueClient theQueue, string newMessage)
    {
        if (null != await theQueue.CreateIfNotExistsAsync())
        {
            Console.WriteLine("The queue was created.");
        }

        return await theQueue.SendMessageAsync(newMessage);
    }
    
    public static async Task<string> RetrieveNextMessageAsync(QueueClient theQueue)
    {
        if (await theQueue.ExistsAsync())
        {
            QueueProperties properties = await theQueue.GetPropertiesAsync();

            if (properties.ApproximateMessagesCount > 0)
            {
                QueueMessage[] retrievedMessage = await theQueue.ReceiveMessagesAsync(1);
                string theMessage = retrievedMessage[0].Body.ToString();
                await theQueue.DeleteMessageAsync(retrievedMessage[0].MessageId, retrievedMessage[0].PopReceipt);
                return theMessage;
            }

            return String.Empty;
        }

        return String.Empty;
    }
}