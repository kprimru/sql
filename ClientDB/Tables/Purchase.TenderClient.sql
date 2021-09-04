USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Purchase].[TenderClient]
(
        [TCL_ID]          UniqueIdentifier      NOT NULL,
        [TCL_ID_TENDER]   UniqueIdentifier      NOT NULL,
        [TCL_NAME]        VarChar(500)          NOT NULL,
        [TCL_PLACE]       VarChar(250)          NOT NULL,
        [TCL_ADDRESS]     VarChar(250)          NOT NULL,
        [TCL_EMAIL]       VarChar(150)          NOT NULL,
        [TCL_RES]         VarChar(150)          NOT NULL,
        [TCL_PHONE]       VarChar(150)          NOT NULL,
        [TCL_FAX]         VarChar(150)          NOT NULL,
        CONSTRAINT [PK_Purchase.TenderClient] PRIMARY KEY NONCLUSTERED ([TCL_ID]),
        CONSTRAINT [FK_Purchase.TenderClient(TCL_ID_TENDER)_Purchase.Tender(TD_ID)] FOREIGN KEY  ([TCL_ID_TENDER]) REFERENCES [Purchase].[Tender] ([TD_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Purchase.TenderClient(TCL_ID_TENDER)] ON [Purchase].[TenderClient] ([TCL_ID_TENDER] ASC);
GO
