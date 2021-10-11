USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientDelivery]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_CLIENT]     Int                   NOT NULL,
        [ID_DELIVERY]   UniqueIdentifier      NOT NULL,
        [EMAIL]         NVarChar(256)         NOT NULL,
        [START]         SmallDateTime         NOT NULL,
        [FINISH]        SmallDateTime             NULL,
        [NOTE]          NVarChar(Max)             NULL,
        [UPD_DATE]      DateTime              NOT NULL,
        [UPD_USER]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientDelivery] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientDelivery(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientDelivery(ID_DELIVERY)_dbo.Delivery(ID)] FOREIGN KEY  ([ID_DELIVERY]) REFERENCES [dbo].[Delivery] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDelivery(ID_CLIENT,FINISH)+(EMAIL)] ON [dbo].[ClientDelivery] ([ID_CLIENT] ASC, [FINISH] ASC) INCLUDE ([EMAIL]);
GO
