USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seminar].[SubjectNotification]
(
        [Id]           Int                Identity(1,1)   NOT NULL,
        [Subject_Id]   UniqueIdentifier                       NULL,
        [EMail]        VarChar(128)                           NULL,
        [Date]         date                                   NULL,
        CONSTRAINT [PK__SubjectN__3214EC07BA683B4D] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [FK__SubjectNo__Subje__7C67B279] FOREIGN KEY  ([Subject_Id]) REFERENCES [Seminar].[Subject] ([ID])
);
GO
