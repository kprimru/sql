USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StudentPositionTable]
(
        [StudentPositionID]     Int            Identity(1,1)   NOT NULL,
        [StudentPositionName]   VarChar(150)                   NOT NULL,
        CONSTRAINT [PK_dbo.StudentPositionTable] PRIMARY KEY CLUSTERED ([StudentPositionID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.StudentPositionTable(StudentPositionName)] ON [dbo].[StudentPositionTable] ([StudentPositionName] ASC);
GO
