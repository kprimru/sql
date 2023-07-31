USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [KGS].[MemoClaim]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [ID_MASTER]      UniqueIdentifier          NULL,
        [TP]             TinyInt               NOT NULL,
        [DATE]           SmallDateTime         NOT NULL,
        [ID_CLIENT]      Int                       NULL,
        [CL_NAME]        NVarChar(512)         NOT NULL,
        [ID_VENDOR]      UniqueIdentifier      NOT NULL,
        [ID_TRADESITE]   UniqueIdentifier      NOT NULL,
        [DATE_LIMIT]     SmallDateTime         NOT NULL,
        [CLAIM_SUM]      Money                 NOT NULL,
        [TENDER_DATE]    SmallDateTime             NULL,
        [TENDER_NUM]     NVarChar(256)             NULL,
        [DETAILS]        NVarChar(Max)         NOT NULL,
        [RTRN]           Bit                       NULL,
        [RTRN_RULE]      NVarChar(128)             NULL,
        [CO_BEGIN]       SmallDateTime             NULL,
        [CO_END]         SmallDateTime             NULL,
        [CO_DISCOUNT]    decimal                   NULL,
        [CO_SUM]         Money                     NULL,
        [NOTE]           NVarChar(Max)             NULL,
        [STATUS]         TinyInt               NOT NULL,
        [UPD_DATE]       DateTime              NOT NULL,
        [UPD_USER]       NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_KGS.MemoClaim] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_KGS.MemoClaim(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_KGS.MemoClaim(ID_VENDOR)_dbo.Vendor(ID)] FOREIGN KEY  ([ID_VENDOR]) REFERENCES [dbo].[Vendor] ([ID])
);
GO
