USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActionPeriod]
(
        [AP_ID]          Int        Identity(1,1)   NOT NULL,
        [AP_ID_AC]       SmallInt                   NOT NULL,
        [AP_ID_PERIOD]   SmallInt                   NOT NULL,
        CONSTRAINT [PK_dbo.ActionPeriod] PRIMARY KEY CLUSTERED ([AP_ID])
);GO
