USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientFinancingEIS]
(
        [Client_Id]   Int                NOT NULL,
        [Date]        SmallDateTime      NOT NULL,
        [Data]        xml                NOT NULL,
        CONSTRAINT [PK_dbo.ClientFinancingEIS] PRIMARY KEY CLUSTERED ([Client_Id],[Date])
);GO
