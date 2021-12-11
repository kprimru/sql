USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientVisitCount]
(
        [ID]           SmallInt      Identity(1,1)   NOT NULL,
        [NAME]         VarChar(50)                   NOT NULL,
        [VISIT_CNT4]   SmallInt                      NOT NULL,
        [VISIT_CNT5]   SmallInt                      NOT NULL,
        CONSTRAINT [PK_dbo.ClientVisitCount] PRIMARY KEY CLUSTERED ([ID])
);
GO
