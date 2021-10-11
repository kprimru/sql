USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrganizationCalc]
(
        [ORGC_ID]        SmallInt       Identity(1,1)   NOT NULL,
        [ORGC_NAME]      VarChar(128)                   NOT NULL,
        [ORGC_ID_ORG]    SmallInt                       NOT NULL,
        [ORGC_ID_BANK]   SmallInt                       NOT NULL,
        [ORGC_ACCOUNT]   VarChar(64)                    NOT NULL,
        [ORGC_ACTIVE]    Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.OrganizationCalc] PRIMARY KEY CLUSTERED ([ORGC_ID])
);GO
