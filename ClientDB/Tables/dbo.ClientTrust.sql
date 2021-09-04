USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientTrust]
(
        [CT_ID]            UniqueIdentifier      NOT NULL,
        [CT_ID_CALL]       UniqueIdentifier      NOT NULL,
        [CT_TNAME]         Bit                   NOT NULL,
        [CT_NAME]          VarChar(500)              NULL,
        [CT_TADDRESS]      Bit                   NOT NULL,
        [CT_ADDRESS]       VarChar(500)              NULL,
        [CT_TDIR]          Bit                   NOT NULL,
        [CT_DIR]           VarChar(250)              NULL,
        [CT_TDIR_POS]      Bit                   NOT NULL,
        [CT_DIR_POS]       VarChar(250)              NULL,
        [CT_TDIR_PHONE]    Bit                   NOT NULL,
        [CT_DIR_PHONE]     VarChar(150)              NULL,
        [CT_TBUH]          Bit                   NOT NULL,
        [CT_BUH]           VarChar(250)              NULL,
        [CT_TBUH_POS]      Bit                   NOT NULL,
        [CT_BUH_POS]       VarChar(250)              NULL,
        [CT_TBUH_PHONE]    Bit                   NOT NULL,
        [CT_BUH_PHONE]     VarChar(150)              NULL,
        [CT_TRES]          Bit                   NOT NULL,
        [CT_RES]           VarChar(250)              NULL,
        [CT_TRES_POS]      Bit                   NOT NULL,
        [CT_RES_POS]       VarChar(150)              NULL,
        [CT_TRES_PHONE]    Bit                   NOT NULL,
        [CT_RES_PHONE]     VarChar(100)              NULL,
        [CT_TRUST]         Bit                   NOT NULL,
        [CT_NOTE]          VarChar(Max)              NULL,
        [CT_MAKE]          DateTime                  NULL,
        [CT_MAKE_USER]     VarChar(128)              NULL,
        [CT_CREATE]        DateTime              NOT NULL,
        [CT_CREATE_USER]   VarChar(128)          NOT NULL,
        CONSTRAINT [PK_dbo.ClientTrust] PRIMARY KEY NONCLUSTERED ([CT_ID]),
        CONSTRAINT [FK_dbo.ClientTrust(CT_ID_CALL)_dbo.ClientCall(CC_ID)] FOREIGN KEY  ([CT_ID_CALL]) REFERENCES [dbo].[ClientCall] ([CC_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientTrust(CT_ID_CALL,CT_ID)] ON [dbo].[ClientTrust] ([CT_ID_CALL] ASC, [CT_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTrust(CT_TRUST,CT_MAKE,CT_ID_CALL)] ON [dbo].[ClientTrust] ([CT_TRUST] ASC, [CT_MAKE] ASC, [CT_ID_CALL] ASC);
GO
