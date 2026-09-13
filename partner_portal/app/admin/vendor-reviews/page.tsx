'use client';
import {useMutation,useQuery,useQueryClient} from '@tanstack/react-query';
import {get,post} from '@/lib/api';
import {Card,PageHeader,Button,Skeleton,ErrorState} from '@/components/ui';
import {useToast} from '@/components/toast';

type VendorReview={id:number;vendorId:number;recommendation:string;confidence:number;reasoning?:string;evidenceJson?:string;requiresHumanApproval:boolean;businessRulePass:boolean;status:string;createdAt:string};
function evidence(value?:string){try{return value?JSON.parse(value):[]}catch{return [value||'No structured evidence available'];}}

export default function VendorReviews(){
  const qc=useQueryClient(); const {toast}=useToast();
  const q=useQuery({queryKey:['vendor-reviews'],queryFn:()=>get<VendorReview[]>('/admin/ai/vendor-reviews')});
  const m=useMutation({mutationFn:({id,approve}:{id:number;approve:boolean})=>post(`/admin/ai/vendor-reviews/${id}/resolve?approve=${approve}`),onSuccess:(_,v)=>{qc.invalidateQueries({queryKey:['vendor-reviews']});toast({title:'Vendor review resolved',message:`Vendor review #${v.id} was updated.`,tone:'success'})}});
  if(q.isLoading)return <><PageHeader title="Pending Vendor Reviews" subtitle="AI pre-screened onboarding submissions awaiting review."/><Skeleton className="h-40"/></>;
  if(q.isError)return <ErrorState message={(q.error as Error).message} onRetry={()=>q.refetch()}/>;
  return <><PageHeader title="Pending Vendor Reviews" subtitle="AI pre-screened onboarding submissions awaiting review."/><div className="space-y-4">{(q.data||[]).map(v=><Card key={v.id} className="p-6"><div className="flex flex-wrap justify-between gap-4"><div><div className="text-xs font-bold uppercase tracking-wider text-gray-500">Review #{v.id} · Vendor #{v.vendorId}</div><div className="mt-2 inline-flex rounded-full bg-mint px-3 py-1 text-xs font-bold uppercase">{v.recommendation}</div><div className="mt-1 text-xs text-gray-500">Confidence: {(v.confidence*100).toFixed(0)}% · Business rules: {v.businessRulePass?'pass':'needs review'}</div></div><div className="flex gap-2"><Button disabled={m.isPending} onClick={()=>m.mutate({id:v.id,approve:true})}>Approve</Button><button disabled={m.isPending} onClick={()=>m.mutate({id:v.id,approve:false})} className="rounded-xl border border-red-200 px-4 py-2.5 text-sm font-semibold text-red-700">Reject</button></div></div><p className="mt-5 text-sm leading-6 text-gray-700">{v.reasoning||'No reasoning recorded.'}</p><div className="mt-4"><div className="text-sm font-bold">Evidence</div><ul className="mt-2 list-disc space-y-1 pl-5 text-sm text-gray-600">{evidence(v.evidenceJson).map((e:any,i:number)=><li key={i}>{typeof e==='string'?e:JSON.stringify(e)}</li>)}</ul></div></Card>)}{!q.data?.length&&<Card className="p-10 text-center text-sm text-gray-500">No pending vendor reviews.</Card>}</div></>;
}
