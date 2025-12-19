from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.ci import GithubActions
from diagrams.onprem.iac import Terraform
from diagrams.onprem.security import Vault
from diagrams.onprem.client import Users
from diagrams.generic.storage import Storage
from diagrams.generic.compute import Rack
from diagrams.aws.security import IAM

with Diagram(
    "Security CI Pipeline – Terraform + Checkov + OPA",
    filename="Diagram/ci_pipeline_diagram",
    show=False,
    direction="LR",
):
    dev = Users("Developer\nPush / PR")
    gha = GithubActions("GitHub Actions\nSecurity CI")

    with Cluster("AWS"):
        oidc = IAM("IAM Role\nOIDC AssumeRole")

    with Cluster("Pipeline"):
        tf = Terraform("Terraform\nfmt · validate · plan")
        checkov = Rack("Checkov\nIaC Scan")
        opa = Vault("OPA Conftest\nPolicy as Code")
        plan = Storage("Terraform Plan\n(tfplan.json)")

    evidence = Storage("Compliance Evidence\nArtifacts")

    dev >> gha
    gha >> Edge(label="OIDC") >> oidc
    gha >> tf
    tf >> plan
    gha >> checkov
    plan >> opa
    checkov >> evidence
    opa >> Edge(label="pass / fail") >> evidence
