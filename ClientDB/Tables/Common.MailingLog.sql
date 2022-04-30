USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[MailingLog]
(
        [id]        Int            Identity(1,1)   NOT NULL,
        [TypeID]    TinyInt                        NOT NULL,
        [Address]   VarChar(256)                   NOT NULL,
        [Subject]   VarChar(256)                   NOT NULL,
        [Body]      VarChar(Max)                       NULL,
        [Date]      DateTime                       NOT NULL,
        [Status]    SmallInt                       NOT NULL,
        [Error]     VarChar(Max)                       NULL,
        CONSTRAINT [PK_Common.MailingLog] PRIMARY KEY CLUSTERED ([id]),
        CONSTRAINT [FK_Common.MailingLog(TypeID)_Common.MailingType(MailingTypeId)] FOREIGN KEY  ([TypeID]) REFERENCES [Common].[MailingType] ([MailingTypeId])
);
GO
CREATE NONCLUSTERED INDEX [IX_Common.MailingLog(Address)] ON [Common].[MailingLog] ([Address] ASC);
CREATE NONCLUSTERED INDEX [IX_Common.MailingLog(Date)] ON [Common].[MailingLog] ([Date] ASC);
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20220307-14475] ON [Common].[MailingLog] ([Date] ASC);
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20220307-144757] ON [Common].[MailingLog] ([Date] ASC);
GO
