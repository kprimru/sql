USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientSearchComments]
(
        [CSC_ID]          UniqueIdentifier      NOT NULL,
        [CSC_ID_CLIENT]   Int                   NOT NULL,
        [CSC_COMMENTS]    xml                       NULL,
        CONSTRAINT [PK_dbo.ClientSearchComments] PRIMARY KEY NONCLUSTERED ([CSC_ID]),
        CONSTRAINT [FK_dbo.ClientSearchComments(CSC_ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([CSC_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientSearchComments(CSC_ID_CLIENT)] ON [dbo].[ClientSearchComments] ([CSC_ID_CLIENT] ASC);
GO
