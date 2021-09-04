USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SearchTable]
(
        [SearchID]         bigint         Identity(1,1)   NOT NULL,
        [SearchDateTime]   DateTime                           NULL,
        [SearchCategory]   VarChar(50)                    NOT NULL,
        [SearchText]       VarChar(250)                   NOT NULL,
        [SearchUser]       VarChar(50)                    NOT NULL,
        [SearchHost]       VarChar(50)                    NOT NULL,
        CONSTRAINT [PK_dbo.SearchTable] PRIMARY KEY NONCLUSTERED ([SearchID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.SearchTable(SearchUser,SearchHost,SearchDateTime,SearchID)] ON [dbo].[SearchTable] ([SearchUser] ASC, [SearchHost] ASC, [SearchDateTime] DESC, [SearchID] ASC);
GO
