USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Claim].[ClaimDetail]
(
        [CLD_ID]          UniqueIdentifier      NOT NULL,
        [CLD_ID_CLAIM]    UniqueIdentifier      NOT NULL,
        [CLD_ID_CLIENT]   UniqueIdentifier      NOT NULL,
        [CLD_ID_VENDOR]   UniqueIdentifier      NOT NULL,
        [CLD_ID_SYSTEM]   UniqueIdentifier      NOT NULL,
        [CLD_ID_TYPE]     UniqueIdentifier      NOT NULL,
        [CLD_ID_NET]      UniqueIdentifier      NOT NULL,
        [CLD_ID_TECH]     UniqueIdentifier      NOT NULL,
        [CLD_COUNT]       TinyInt               NOT NULL,
        [CLD_COMMENT]     VarChar(50)               NULL,
        CONSTRAINT [PK_Claim.ClaimDetail] PRIMARY KEY CLUSTERED ([CLD_ID]),
        CONSTRAINT [FK_Claim.ClaimDetail(CLD_ID_NET)_Claim.NetType(NTMS_ID)] FOREIGN KEY  ([CLD_ID_NET]) REFERENCES [Distr].[NetType] ([NTMS_ID]),
        CONSTRAINT [FK_Claim.ClaimDetail(CLD_ID_SYSTEM)_Claim.Systems(SYSMS_ID)] FOREIGN KEY  ([CLD_ID_SYSTEM]) REFERENCES [Distr].[Systems] ([SYSMS_ID]),
        CONSTRAINT [FK_Claim.ClaimDetail(CLD_ID_TECH)_Claim.TechType(TTMS_ID)] FOREIGN KEY  ([CLD_ID_TECH]) REFERENCES [Distr].[TechType] ([TTMS_ID]),
        CONSTRAINT [FK_Claim.ClaimDetail(CLD_ID_TYPE)_Claim.DistrType(DTMS_ID)] FOREIGN KEY  ([CLD_ID_TYPE]) REFERENCES [Distr].[DistrType] ([DTMS_ID]),
        CONSTRAINT [FK_Claim.ClaimDetail(CLD_ID_CLIENT)_Claim.Clients(CLMS_ID)] FOREIGN KEY  ([CLD_ID_CLIENT]) REFERENCES [Clients].[Clients] ([CLMS_ID]),
        CONSTRAINT [FK_Claim.ClaimDetail(CLD_ID_CLAIM)_Claim.Claims(CLM_ID)] FOREIGN KEY  ([CLD_ID_CLAIM]) REFERENCES [Claim].[Claims] ([CLM_ID]),
        CONSTRAINT [FK_Claim.ClaimDetail(CLD_ID_VENDOR)_Claim.Vendors(VDMS_ID)] FOREIGN KEY  ([CLD_ID_VENDOR]) REFERENCES [Clients].[Vendors] ([VDMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Claim.ClaimDetail(CLD_ID_CLAIM)] ON [Claim].[ClaimDetail] ([CLD_ID_CLAIM] ASC);
GO
